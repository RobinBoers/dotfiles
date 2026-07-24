import { getAgentDir, type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { Credential, CredentialStore } from "@earendil-works/pi-ai";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const PROVIDER = "openai-codex";
const PREFIX = `${PROVIDER}:`;

type Config = {
	active?: string;
};

const configPath = join(getAgentDir(), "identity.json");
const providerKey = (account: string) => `${PREFIX}${account}`;

function readConfig(): Config {
	if (!existsSync(configPath)) return {};
	try {
		const config = JSON.parse(readFileSync(configPath, "utf8"));
		return typeof config.active == "string" ? { active: config.active } : {};
	} catch {
		return {};
	}
}

function writeConfig(config: Config): void {
	writeFileSync(configPath, `${JSON.stringify(config, null, 2)}\n`, { mode: 0o600 });
}

function credentialStore(ctx: ExtensionContext): CredentialStore {
	return (
		ctx.modelRegistry as unknown as {
			runtime: { credentials: CredentialStore };
		}
	).runtime.credentials;
}

async function accounts(ctx: ExtensionContext): Promise<string[]> {
	return (await credentialStore(ctx).list())
		.map(({ providerId }) => providerId)
		.filter((key) => key.startsWith(PREFIX))
		.map((key) => key.slice(PREFIX.length))
		.sort();
}

function credentialFor(ctx: ExtensionContext, account: string): Promise<Credential | undefined> {
	return credentialStore(ctx).read(providerKey(account));
}

function activeAccount(): string | undefined {
	return readConfig().active;
}

async function saveActiveCredential(ctx: ExtensionContext): Promise<void> {
	const account = activeAccount();
	const credential = await credentialStore(ctx).read(PROVIDER);
	if (account && credential) {
		await credentialStore(ctx).modify(providerKey(account), async () => credential);
	}
}

async function switchAccount(ctx: ExtensionContext, account: string): Promise<boolean> {
	if (account == activeAccount() && (await credentialStore(ctx).read(PROVIDER))) {
		await saveActiveCredential(ctx);
		return true;
	}

	const credential = await credentialFor(ctx, account);
	if (!credential) return false;

	await saveActiveCredential(ctx);
	await credentialStore(ctx).modify(PROVIDER, async () => credential);
	writeConfig({ active: account });
	return true;
}

function renderAccountHeader(account: string | undefined, theme: any, hasMessages: boolean): string[] {
	const text = account ?? "no codex account";
	const art: Record<string, string[]> = {
		"eleven.ai": [
			"███████╗██╗     ███████╗██╗   ██╗███████╗███╗   ██╗   █████╗ ██╗",
			"██╔════╝██║     ██╔════╝██║   ██║██╔════╝████╗  ██║  ██╔══██╗██║",
			"█████╗  ██║     █████╗  ██║   ██║█████╗  ██╔██╗ ██║  ███████║██║",
			"██╔══╝  ██║     ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║  ██╔══██║██║",
			"███████╗███████╗███████╗ ╚████╔╝ ███████╗██║ ╚████║  ██║  ██║██║",
			"╚══════╝╚══════╝╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝  ╚═╝  ╚═╝╚═╝",
		],
		"qdentity.ai": [
			" ██████╗ ██████╗ ███████╗███╗   ██╗████████╗██╗████████╗██╗   ██╗   █████╗ ██╗",
			"██╔═══██╗██╔══██╗██╔════╝████╗  ██║╚══██╔══╝██║╚══██╔══╝╚██╗ ██╔╝  ██╔══██╗██║",
			"██║   ██║██║  ██║█████╗  ██╔██╗ ██║   ██║   ██║   ██║    ╚████╔╝   ███████║██║",
			"██║▄▄ ██║██║  ██║██╔══╝  ██║╚██╗██║   ██║   ██║   ██║     ╚██╔╝    ██╔══██║██║",
			"╚██████╔╝██████╔╝███████╗██║ ╚████║   ██║   ██║   ██║      ██║     ██║  ██║██║",
			" ╚══▀▀═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝   ╚═╝      ╚═╝     ╚═╝  ╚═╝╚═╝",
		],
	};

	const lines = account && art[account] ? ["", ...art[account]] : [text];
	const header = [...lines.map((line) => theme.fg("accent", line)), theme.fg("dim", " use /identity to switch")];
	return hasMessages ? [...header, ""] : header;
}

function applyHeader(ctx: ExtensionContext): void {
	if (ctx.mode !== "tui") return;
	ctx.ui.setHeader((_tui, theme) => ({
		invalidate() {},
		render() {
			const hasMessages = ctx.sessionManager.getEntries().some((entry: any) => entry.type === "message");
			return renderAccountHeader(activeAccount(), theme, hasMessages);
		},
	}));
}

async function promptAccount(ctx: ExtensionContext, message: string): Promise<string | undefined> {
	return (await ctx.ui.input(message, ""))?.trim() || undefined;
}

async function selectAccount(ctx: ExtensionContext, message: string): Promise<string | undefined> {
	const available = await accounts(ctx);
	if (available.length == 0) return undefined;
	return await ctx.ui.select(message, available);
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		const account = activeAccount();
		if (account) await switchAccount(ctx, account);
		applyHeader(ctx);
	});

	pi.on("agent_settled", (_event, ctx) => saveActiveCredential(ctx));
	pi.on("session_shutdown", (_event, ctx) => saveActiveCredential(ctx));

	pi.registerCommand("identity", {
		description: "Pick active identity",
		handler: async (args, ctx) => {
			const requested = args.trim() || (await selectAccount(ctx, "Identity"));
			if (!requested) {
				ctx.ui.notify("No Codex identities saved. Run /login openai-codex, then /save-identity <name>.", "error");
				return;
			}

			if (!(await switchAccount(ctx, requested))) {
				ctx.ui.notify(`No saved Codex identity named ${requested}. Run /login openai-codex, then /save-identity ${requested}.`, "error");
				return;
			}

			applyHeader(ctx);
			ctx.ui.notify(`Codex account: ${requested}`, "info");
		},
	});

	pi.registerCommand("save-identity", {
		description: "Save current openai-codex credential as an identity",
		handler: async (args, ctx) => {
			const requested = args.trim() || (await promptAccount(ctx, "Save current credential as"));
			if (!requested) return;

			const credential = await credentialStore(ctx).read(PROVIDER);
			if (!credential) {
				ctx.ui.notify("No active openai-codex credential to save. Run /login openai-codex first.", "error");
				return;
			}

			await credentialStore(ctx).modify(providerKey(requested), async () => credential);
			writeConfig({ active: requested });
			applyHeader(ctx);
			ctx.ui.notify(`Saved current Codex credential as ${requested}`, "info");
		},
	});
}
