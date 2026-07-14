import {
	CustomEditor,
	getAgentDir,
	type ExtensionAPI,
	type KeybindingsManager,
} from "@earendil-works/pi-coding-agent";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import type { EditorTheme, TUI } from "@earendil-works/pi-tui";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const ansiPattern = /\x1b(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~]|\][^\x07]*(?:\x07|\x1b\\)|P[^\x1b]*(?:\x1b\\))/g;

function stripAnsi(text: string): string {
	return text.replace(ansiPattern, "");
}

function isEditorRule(line: string): boolean {
	const plain = stripAnsi(line);
	return /^[─↑↓ 0-9more]+$/.test(plain) && plain.includes("─");
}

function padToWidth(text: string, width: number): string {
	return text + " ".repeat(Math.max(0, width - visibleWidth(text)));
}

function fit(text: string, width: number): string {
	return padToWidth(truncateToWidth(text, width, ""), width);
}

function bgGray(text: string): string {
	const start = "\x1b[48;5;236m";
	const reset = "\x1b[0m";
	return `${start}${text.replaceAll(reset, `${reset}${start}`)}${reset}`;
}

function kfmt(value: number | null | undefined): string {
	const count = value ?? 0;
	if (count >= 1000) return `${Math.round(count / 100) / 10}k`;
	return `${Math.floor(count)}`;
}

function usd(value: number): string {
	return `$${value.toFixed(2)}`;
}

function duration(ms: number): string {
	const seconds = Math.max(0, Math.floor(ms / 1000));
	if (seconds >= 3600) return `${Math.floor(seconds / 3600)}h${Math.floor((seconds % 3600) / 60)}m`;
	if (seconds >= 60) return `${Math.floor(seconds / 60)}m${seconds % 60}s`;
	return `${seconds}s`;
}

function lastPathParts(path: string): string {
	const parts = path.split("/").filter(Boolean);
	return parts.slice(-2).join("/") || path;
}

function activeIdentity(): string | undefined {
	const path = join(getAgentDir(), "identity.json");
	if (!existsSync(path)) return undefined;

	try {
		const config = JSON.parse(readFileSync(path, "utf8"));
		return typeof config.active === "string" ? config.active : undefined;
	} catch {
		return undefined;
	}
}

function accountName(ctx: { model: any; modelRegistry: any }): string {
	const provider = ctx.model?.provider;
	if (!provider) return "no account";
	if (provider === "openai-codex") return activeIdentity() ?? "codex";

	const credential = ctx.modelRegistry.authStorage.get(provider) as any;
	return (
		process.env.PI_ACCOUNT_NAME ||
		credential?.accountName ||
		ctx.modelRegistry.getProviderAuthStatus(provider).label ||
		ctx.modelRegistry.getProviderDisplayName(provider) ||
		provider
	);
}

function totalCost(ctx: { sessionManager: any }): number {
	return ctx.sessionManager.getEntries().reduce((cost: number, entry: any) => {
		if (entry.type != "message" || entry.message.role != "assistant") return cost;
		return cost + (entry.message.usage?.cost?.total ?? 0);
	}, 0);
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		ctx.ui.setFooter((_tui, theme) => ({
			invalidate() {},
			render(width: number): string[] {
				const context = ctx.getContextUsage();
				const effort = pi.getThinkingLevel();
				const model = ctx.model?.id ?? "no model";
				const leftPlain = `[${lastPathParts(ctx.cwd)}] ${model} (${effort})`;
				const left = `${theme.bold(`[${lastPathParts(ctx.cwd)}] `)}${model}${theme.fg("dim", ` (${effort})`)}`;
				const account = accountName(ctx);
				const startedAt = new Date(ctx.sessionManager.getHeader().timestamp).getTime();
				const rightStats = `  ${duration(Date.now() - startedAt)} | ${kfmt(context?.tokens)}/${kfmt(context?.contextWindow)} | ${usd(totalCost(ctx))}`;
				const rightPlain = `${account}${rightStats}`;
				const right = `${account}${theme.fg("dim", rightStats)}`;
				const sidePad = " ";
				const innerWidth = Math.max(1, width - visibleWidth(sidePad) * 2);
				const padding = " ".repeat(Math.max(1, innerWidth - visibleWidth(leftPlain) - visibleWidth(rightPlain)));
				return [truncateToWidth(`${sidePad}${left}${padding}${right}${sidePad}`, width, "")];
			},
		}));

		class CodexEditor extends CustomEditor {
			constructor(tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager) {
				super(tui, theme, keybindings, { paddingX: 0 });
			}

			render(width: number): string[] {
				if (width < 8) return super.render(width);

				const prompt = "> ";
				const gutter = "  ";
				const contentWidth = Math.max(1, width - 3 - visibleWidth(prompt));
				const source = super.render(contentWidth);
				const lines: string[] = [bgGray(" ".repeat(width))];
				let isFirstContentLine = true;

				for (const line of source) {
					if (isEditorRule(line)) continue;

					const prefix = isFirstContentLine ? prompt : gutter;
					isFirstContentLine = false;
					lines.push(bgGray(` ${prefix}${fit(line, contentWidth)}  `));
				}

				if (isFirstContentLine) {
					lines.push(bgGray(` ${prompt}${" ".repeat(contentWidth)}  `));
				}

				lines.push(bgGray(" ".repeat(width)));
				return lines;
			}
		}

		ctx.ui.setEditorComponent((tui, theme, keybindings) => new CodexEditor(tui, theme, keybindings));
	});
}
