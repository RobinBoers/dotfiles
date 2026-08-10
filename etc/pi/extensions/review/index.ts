import { spawn, type ChildProcessByStdio } from "node:child_process"
import { existsSync, readFileSync } from "node:fs"
import { basename, dirname, join } from "node:path"
import type { Readable } from "node:stream"
import { fileURLToPath } from "node:url"
import type { Message } from "@earendil-works/pi-ai"
import {
  getMarkdownTheme,
  truncateHead,
  type ExtensionAPI,
  type ExtensionCommandContext,
} from "@earendil-works/pi-coding-agent"
import { Container, Markdown, Spacer, Text } from "@earendil-works/pi-tui"

const REVIEW_MESSAGE_TYPE = "codex-review"
const REVIEW_TOOLS = "read,grep,find,ls,bash"
const MAX_STDERR_BYTES = 64 * 1024

const REVIEW_PROMPT = readFileSync(
  join(dirname(fileURLToPath(import.meta.url)), "rubric.md"),
  "utf8",
)

type ReviewTarget =
  | { kind: 'uncommitted' }
  | { kind: 'base'; branch: string }
  | { kind: 'commit'; sha: string; title: string }
  | { kind: 'custom'; instructions: string }

type ReviewFinding = {
  title: string
  body: string
  confidence_score: number
  priority?: number | null
  code_location: {
    absolute_file_path: string
    line_range: { start: number; end: number }
  }
}

type ReviewOutput = {
  findings: ReviewFinding[]
  overall_correctness: "patch is correct" | "patch is incorrect"
  overall_explanation: string
  overall_confidence_score: number
}

type ReviewDetails = {
  target: string
  model: string
  output?: ReviewOutput
}

type GitResult = { stdout: string; stderr: string; code: number }
type ReviewChild = ChildProcessByStdio<null, Readable, Readable>

const isRecord = (value: unknown): value is Record<string, unknown> =>
  !!value && typeof value == "object" && !Array.isArray(value)

const extractText = (message: Message): string => {
  if (message.role != "assistant") return ""

  return message.content
    .filter((part): part is { type: "text"; text: string } => part.type == "text")
    .map((part) => part.text)
    .join("\n")
    .trim()
}

const isReviewFinding = (value: unknown): value is ReviewFinding => {
  if (!isRecord(value) || !isRecord(value.code_location)) return false
  const range = value.code_location.line_range

  return (
    typeof value.title == "string" &&
    typeof value.body == "string" &&
    typeof value.confidence_score == "number" &&
    typeof value.code_location.absolute_file_path == "string" &&
    isRecord(range) &&
    typeof range.start == "number" &&
    typeof range.end == "number"
  )
}

const isReviewOutput = (value: unknown): value is ReviewOutput =>
  isRecord(value) &&
  Array.isArray(value.findings) &&
  value.findings.every(isReviewFinding) &&
  (value.overall_correctness == "patch is correct" || value.overall_correctness == "patch is incorrect") &&
  typeof value.overall_explanation == "string" &&
  typeof value.overall_confidence_score == "number"

const parseReviewOutput = (text: string): ReviewOutput | undefined => {
  const candidates = [text]
  const start = text.indexOf("{")
  const end = text.lastIndexOf("}")
  if (start >= 0 && end > start) candidates.push(text.slice(start, end + 1))

  for (const candidate of candidates) {
    try {
      const parsed: unknown = JSON.parse(candidate)
      if (isReviewOutput(parsed)) return parsed
    } catch {}
  }

  return undefined
}

const relativeLocation = (finding: ReviewFinding, cwd: string): string => {
  const prefix = `${cwd}/`
  const path = finding.code_location.absolute_file_path.startsWith(prefix)
    ? finding.code_location.absolute_file_path.slice(prefix.length)
    : finding.code_location.absolute_file_path
  const { start, end } = finding.code_location.line_range
  return `${path}:${start}${end == start ? "" : `-${end}`}`
}

const renderReview = (output: ReviewOutput, cwd: string): string => {
  const verdict = output.overall_correctness == "patch is correct" ? "Patch is correct" : "Patch is incorrect"
  const findings = output.findings.length == 0
    ? "No findings."
    : output.findings
        .map((finding, index) => [
          `### ${index + 1}. ${finding.title}`,
          `**${relativeLocation(finding, cwd)}**`,
          finding.body,
        ].join("\n\n"))
        .join("\n\n")

  return [
    `## ${verdict}`,
    output.overall_explanation,
    "## Findings",
    findings,
  ].join("\n\n")
}

const targetLabel = (target: ReviewTarget): string => {
  switch (target.kind) {
    case 'uncommitted': return "current changes"
    case 'base': return `changes against '${target.branch}'`
    case 'commit': return `commit ${target.sha.slice(0, 7)}: ${target.title}`
    case 'custom': return target.instructions
  }
}

const git = async (
  pi: ExtensionAPI,
  cwd: string,
  args: string[],
): Promise<GitResult> => pi.exec("git", args, { cwd, timeout: 10_000 })

const chooseBaseBranch = async (
  pi: ExtensionAPI,
  ctx: ExtensionCommandContext,
): Promise<ReviewTarget | undefined> => {
  const result = await git(pi, ctx.cwd, [
    "for-each-ref",
    "--format=%(refname:short)",
    "--sort=-committerdate",
    "refs/heads",
  ])
  if (result.code != 0) throw new Error(result.stderr.trim() || "Could not list Git branches")

  const branches = result.stdout.split("\n").map((branch) => branch.trim()).filter(Boolean)
  if (branches.length == 0) throw new Error("No local Git branches found")

  const currentResult = await git(pi, ctx.cwd, ["branch", "--show-current"])
  const current = currentResult.stdout.trim() || "(detached HEAD)"
  const labels = branches.map((branch) => `${current} -> ${branch}`)
  const selected = await ctx.ui.select("Select a base branch", labels)
  if (!selected) return undefined

  return { kind: 'base', branch: branches[labels.indexOf(selected)] }
}

const chooseCommit = async (
  pi: ExtensionAPI,
  ctx: ExtensionCommandContext,
): Promise<ReviewTarget | undefined> => {
  const result = await git(pi, ctx.cwd, ["log", "-100", "--format=%H%x09%s"])
  if (result.code != 0) throw new Error(result.stderr.trim() || "Could not list Git commits")

  const commits = result.stdout
    .split("\n")
    .filter(Boolean)
    .map((line) => {
      const separator = line.indexOf("\t")
      return { sha: line.slice(0, separator), title: line.slice(separator + 1) }
    })
  if (commits.length == 0) throw new Error("No Git commits found")

  const labels = commits.map(({ sha, title }) => `${title}  ${sha.slice(0, 8)}`)
  const selected = await ctx.ui.select("Select a commit to review", labels)
  if (!selected) return undefined

  const commit = commits[labels.indexOf(selected)]
  return { kind: 'commit', ...commit }
}

const chooseTarget = async (
  pi: ExtensionAPI,
  args: string,
  ctx: ExtensionCommandContext,
): Promise<ReviewTarget | undefined> => {
  if (args.trim()) return { kind: 'custom', instructions: args.trim() }
  if (!ctx.hasUI) throw new Error("Use /review <custom instructions> outside the interactive TUI")

  const selected = await ctx.ui.select("Select a review preset", [
    "Review against a base branch (PR style)",
    "Review uncommitted changes",
    "Review a commit",
    "Custom review instructions",
  ])

  switch (selected) {
    case "Review against a base branch (PR style)": return chooseBaseBranch(pi, ctx)
    case "Review uncommitted changes": return { kind: 'uncommitted' }
    case "Review a commit": return chooseCommit(pi, ctx)
    case "Custom review instructions": {
      const instructions = await ctx.ui.editor("Custom review instructions", "")
      return instructions?.trim() ? { kind: 'custom', instructions: instructions.trim() } : undefined
    }
    default: return undefined
  }
}

const buildUserPrompt = async (
  pi: ExtensionAPI,
  cwd: string,
  target: ReviewTarget,
): Promise<string> => {
  switch (target.kind) {
    case 'uncommitted':
      return "Review the current code changes (staged, unstaged, and untracked files) and provide prioritized findings."
    case 'commit':
      return `Review the code changes introduced by commit ${target.sha} ("${target.title}"). Provide prioritized, actionable findings.`
    case 'custom':
      return target.instructions
    case 'base': {
      const mergeBase = await git(pi, cwd, ["merge-base", "HEAD", target.branch])
      if (mergeBase.code == 0 && mergeBase.stdout.trim()) {
        return `Review the code changes against the base branch '${target.branch}'. The merge base commit for this comparison is ${mergeBase.stdout.trim()}. Run \`git diff ${mergeBase.stdout.trim()}\` to inspect the changes relative to ${target.branch}. Provide prioritized, actionable findings.`
      }
      return `Review the code changes against the base branch '${target.branch}'. Find its merge base with HEAD, inspect the diff against that SHA, and provide prioritized, actionable findings.`
    }
  }
}

const getPiInvocation = (args: string[]): { command: string; args: string[] } => {
  const currentScript = process.argv[1]
  const isBunVirtualScript = currentScript?.startsWith("/$bunfs/root/")
  if (currentScript && !isBunVirtualScript && existsSync(currentScript)) {
    return { command: process.execPath, args: [currentScript, ...args] }
  }

  const executable = basename(process.execPath).toLowerCase()
  if (!/^(node|bun)(\.exe)?$/.test(executable)) return { command: process.execPath, args }
  return { command: "pi", args }
}

const runReview = async (
  cwd: string,
  model: string,
  thinking: string,
  prompt: string,
  onActivity: (activity: string) => void,
  onSpawn: (child: ReviewChild) => void,
): Promise<string> => {
  const args = [
    "--mode", "json",
    "--print",
    "--no-session",
    "--no-extensions",
    "--no-skills",
    "--no-prompt-templates",
    "--no-themes",
    "--tools", REVIEW_TOOLS,
    "--model", model,
    "--thinking", thinking,
    "--system-prompt", REVIEW_PROMPT,
    prompt,
  ]
  const invocation = getPiInvocation(args)

  return new Promise((resolve, reject) => {
    const child = spawn(invocation.command, invocation.args, {
      cwd,
      shell: false,
      stdio: ["ignore", "pipe", "pipe"],
    })
    onSpawn(child)

    let stdoutBuffer = ""
    let stderr = ""
    let finalText = ""
    let modelError = ""

    const processLine = (line: string) => {
      if (!line.trim()) return

      try {
        const event = JSON.parse(line)
        if (event.type == "tool_execution_start") {
          onActivity(`Reviewing: ${event.toolName}`)
        }
        if (event.type == "message_end" && event.message?.role == "assistant") {
          finalText = extractText(event.message as Message) || finalText
          modelError = event.message.errorMessage || modelError
        }
      } catch {}
    }

    child.stdout.on("data", (data: Buffer) => {
      stdoutBuffer += data.toString()
      const lines = stdoutBuffer.split("\n")
      stdoutBuffer = lines.pop() || ""
      lines.forEach(processLine)
    })
    child.stderr.on("data", (data: Buffer) => {
      if (Buffer.byteLength(stderr) < MAX_STDERR_BYTES) stderr += data.toString()
    })
    child.on("error", reject)
    child.on("close", (code) => {
      processLine(stdoutBuffer)
      if (code != 0 || modelError) {
        reject(new Error(modelError || stderr.trim() || `Review process exited with code ${code}`))
        return
      }
      if (!finalText) {
        reject(new Error(stderr.trim() || "Reviewer returned no output"))
        return
      }
      resolve(finalText)
    })
  })
}

export default function reviewExtension(pi: ExtensionAPI) {
  let child: ReviewChild | undefined

  pi.registerMessageRenderer(REVIEW_MESSAGE_TYPE, (message, { outputPad }, theme) => {
    const details = message.details as ReviewDetails | undefined
    const container = new Container()
    container.addChild(new Text(theme.fg("accent", theme.bold(`Review: ${details?.target || "custom"}`)), outputPad, 0))
    container.addChild(new Spacer(1))
    const content = typeof message.content == "string"
      ? message.content
      : message.content
          .filter((part): part is { type: "text"; text: string } => part.type == "text")
          .map((part) => part.text)
          .join("\n")
    container.addChild(new Markdown(content, outputPad, 0, getMarkdownTheme()))
    if (details?.model) {
      container.addChild(new Spacer(1))
      container.addChild(new Text(theme.fg("dim", details.model), outputPad, 0))
    }
    return container
  })

  pi.on("session_shutdown", () => {
    child?.kill("SIGTERM")
    child = undefined
  })

  pi.registerCommand("review", {
    description: "Review changes with an isolated Codex-style reviewer",
    handler: async (args, ctx) => {
      if (!ctx.isIdle()) await ctx.waitForIdle()

      try {
        const target = await chooseTarget(pi, args, ctx)
        if (!target) return

        const repository = await git(pi, ctx.cwd, ["rev-parse", "--show-toplevel"])
        if (repository.code != 0) throw new Error("/review must run inside a Git repository")

        const model = ctx.model
        if (!model) throw new Error("No active model")
        const modelName = `${model.provider}/${model.id}`
        const prompt = await buildUserPrompt(pi, ctx.cwd, target)

        ctx.ui.setStatus(REVIEW_MESSAGE_TYPE, "Reviewing")
        const rawOutput = await runReview(
          ctx.cwd,
          modelName,
          pi.getThinkingLevel(),
          prompt,
          (activity) => ctx.ui.setStatus(REVIEW_MESSAGE_TYPE, activity),
          (process) => { child = process },
        )
        child = undefined

        const output = parseReviewOutput(rawOutput)
        const rendered = output ? renderReview(output, ctx.cwd) : rawOutput
        const truncated = truncateHead(rendered)
        pi.sendMessage({
          customType: REVIEW_MESSAGE_TYPE,
          content: truncated.content,
          display: true,
          details: { target: targetLabel(target), model: modelName, output } satisfies ReviewDetails,
        })
      } catch (error) {
        child?.kill("SIGTERM")
        child = undefined
        const message = error instanceof Error ? error.message : String(error)
        ctx.ui.notify(`Review failed: ${message}`, "error")
      } finally {
        ctx.ui.setStatus(REVIEW_MESSAGE_TYPE, undefined)
      }
    },
  })
}
