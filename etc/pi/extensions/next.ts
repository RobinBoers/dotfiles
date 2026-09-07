import type {
	ExtensionAPI,
	ExtensionCommandContext,
	SessionManager,
} from "@earendil-works/pi-coding-agent";

export async function startNextStep(
	ctx: ExtensionCommandContext,
	setup?: (session: SessionManager) => void,
): Promise<void> {
	await ctx.newSession({
		setup,
		withSession: async (replacementCtx) => {
			await replacementCtx.sendUserMessage("/skill:implement", {
				expandPromptTemplates: true,
			});
		},
	});
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("next", {
		description: "Start a new session and implement the next plan step",
		handler: async (_args, ctx) => {
			await startNextStep(ctx);
		},
	});
}
