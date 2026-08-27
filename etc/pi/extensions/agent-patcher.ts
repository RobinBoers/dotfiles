import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { existsSync, readdirSync, readFileSync, realpathSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join, relative } from "node:path";

type Replacement = {
	old: string;
	new: string;
};

type FilePatch = {
	path: string;
	replacements: Replacement[];
};

type RuntimeStdoutFilter = {
	event: "session_shutdown";
	reason?: string;
	contains: string;
};

type PatchSpec = {
	name?: string;
	description?: string;
	files?: FilePatch[];
	runtimeStdoutFilters?: RuntimeStdoutFilter[];
};

type PatchResult = {
	name: string;
	status: "applied" | "current" | "failed";
	message: string;
};

function agentDir(): string {
	return process.env.PI_CODING_AGENT_DIR ?? join(homedir(), ".pi", "agent");
}

function piPackageRoot(): string {
	let dir = dirname(realpathSync(process.argv[1]));

	while (dir != dirname(dir)) {
		const packageJson = join(dir, "package.json");
		if (existsSync(packageJson)) {
			const pkg = JSON.parse(readFileSync(packageJson, "utf8")) as { name?: string };
			if (pkg.name == "@earendil-works/pi-coding-agent") return dir;
		}

		dir = dirname(dir);
	}

	throw new Error("Could not find @earendil-works/pi-coding-agent package root");
}

function countOccurrences(haystack: string, needle: string): number {
	if (needle == "") return haystack.length + 1;

	let count = 0;
	let offset = 0;

	while (true) {
		const index = haystack.indexOf(needle, offset);
		if (index == -1) return count;
		count++;
		offset = index + needle.length;
	}
}

function readPatchSpecs(patchesDir: string): PatchSpec[] {
	if (!existsSync(patchesDir)) return [];

	return readdirSync(patchesDir)
		.filter((file) => file.endsWith(".json"))
		.sort()
		.map((file) => {
			const path = join(patchesDir, file);
			return {
				name: file,
				...(JSON.parse(readFileSync(path, "utf8")) as PatchSpec),
			};
		});
}

function patchTargets(root: string, pattern: string): string[] {
	if (!pattern.includes("*")) return [join(root, pattern)];

	const expression = new RegExp(
		`^${pattern
			.split("*")
			.map((part) => part.replace(/[\\^$+.()|[\]{}]/g, "\\$&"))
			.join("[^/]*")}$`,
	);
	const prefix = pattern.slice(0, pattern.indexOf("*"));
	const base = join(root, prefix.slice(0, prefix.lastIndexOf("/")));
	const pending = [base];
	const matches: string[] = [];

	while (pending.length > 0) {
		const directory = pending.pop()!;
		for (const entry of readdirSync(directory, { withFileTypes: true })) {
			const path = join(directory, entry.name);
			if (entry.isDirectory()) pending.push(path);
			else if (expression.test(relative(root, path).replaceAll("\\", "/"))) matches.push(path);
		}
	}

	return matches;
}

function applyPatchSpec(root: string, spec: PatchSpec): PatchResult[] {
	const name = spec.name ?? "unnamed patch";
	const results: PatchResult[] = [];

	for (const filePatch of spec.files ?? []) {
		const targets = patchTargets(root, filePatch.path).filter((target) => existsSync(target));
		const viable = targets.filter((target) => {
			const content = readFileSync(target, "utf8");
			return filePatch.replacements.every((replacement) => {
				const oldCount = countOccurrences(content, replacement.old);
				const newCount = countOccurrences(content, replacement.new);
				return oldCount == 1 || (oldCount == 0 && replacement.new != "" && newCount > 0);
			});
		});

		if (viable.length != 1) {
			results.push({
				name,
				status: "failed",
				message: `${filePatch.path}: expected one matching file, found ${viable.length}`,
			});
			continue;
		}

		const target = viable[0];
		let content = readFileSync(target, "utf8");
		let changed = false;
		let failed = false;

		for (const replacement of filePatch.replacements) {
			const oldCount = countOccurrences(content, replacement.old);
			const newCount = countOccurrences(content, replacement.new);

			if (oldCount == 1) {
				content = content.replace(replacement.old, replacement.new);
				changed = true;
				continue;
			}

			if (oldCount == 0 && newCount > 0) continue;

			failed = true;
			results.push({
				name,
				status: "failed",
				message: `${filePatch.path}: expected one match, found ${oldCount}`,
			});
		}

		if (!failed && changed) {
			writeFileSync(target, content);
			results.push({ name, status: "applied", message: filePatch.path });
		} else if (!failed) {
			results.push({ name, status: "current", message: filePatch.path });
		}
	}

	return results;
}

function installShutdownStdoutFilters(filters: RuntimeStdoutFilter[]): void {
	if (filters.length == 0) return;

	const originalWrite = process.stdout.write;
	let installed = false;

	process.stdout.write = function patchedWrite(chunk: unknown, ...args: unknown[]) {
		if (installed) {
			const text = typeof chunk == "string" ? chunk : Buffer.isBuffer(chunk) ? chunk.toString("utf8") : undefined;
			if (text && filters.some((filter) => text.includes(filter.contains))) return true;
		}

		return originalWrite.call(this, chunk as never, ...(args as never[]));
	} as typeof process.stdout.write;

	process.once("exit", () => {
		process.stdout.write = originalWrite;
	});

	for (const filter of filters) {
		if (filter.event != "session_shutdown") continue;
		installed = true;
	}
}

export default function (pi: ExtensionAPI) {
	const patchesDir = join(agentDir(), "patches");
	const specs = readPatchSpecs(patchesDir);
	const root = piPackageRoot();
	const results = specs.flatMap((spec) => applyPatchSpec(root, spec));
	const runtimeFilters = specs.flatMap((spec) => spec.runtimeStdoutFilters ?? []);
	let pendingShutdownFilters: RuntimeStdoutFilter[] = [];

	pi.on("session_start", (_event, ctx) => {
		const applied = results.filter((result) => result.status == "applied");
		const failed = results.filter((result) => result.status == "failed");

		if (applied.length > 0) {
			ctx.ui.notify(`Applied ${applied.length} pi patch(es). Restart pi for disk patches to affect loaded modules.`, "info");
		}

		for (const result of failed) {
			ctx.ui.notify(`Pi patch failed: ${result.name}: ${result.message}`, "error");
		}
	});

	pi.on("session_shutdown", (event) => {
		pendingShutdownFilters = runtimeFilters.filter(
			(filter) => filter.event == "session_shutdown" && (filter.reason == undefined || filter.reason == event.reason),
		);
		installShutdownStdoutFilters(pendingShutdownFilters);
	});
}
