import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { startNextStep } from "./next.ts";

const STATE_TYPE = "ralph-state";
const MAX_TURNS = 10;
const NEXT_MARKER = "Next up";
const DONE_MARKER = "I'm done baby.";

type RalphState = {
	active: boolean;
	turn: number;
};

function ralphState(ctx: ExtensionContext): RalphState | undefined {
	return ctx.sessionManager
		.getBranch()
		.filter((entry) => entry.type == 'custom' && entry.customType == STATE_TYPE)
		.at(-1)?.data as RalphState | undefined;
}

function finalLine(messages: unknown[]): string | undefined {
	const message = messages
		.filter((candidate): candidate is { role: string; content: unknown } =>
			typeof candidate == "object" && candidate != null && "role" in candidate && "content" in candidate,
		)
		.filter((candidate) => candidate.role == "assistant")
		.at(-1);
	if (!message || !Array.isArray(message.content)) return;

	return message.content
		.filter((block): block is { type: "text"; text: string } =>
			typeof block == "object" &&
			block != null &&
			"type" in block &&
			block.type == "text" &&
			"text" in block &&
			typeof block.text == "string",
		)
		.map((block) => block.text)
		.join("\n")
		.trimEnd()
		.split(/\r?\n/)
		.at(-1)
		?.trim();
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("ralph", {
		description: `Implement plan steps automatically, up to ${MAX_TURNS} turns`,
		handler: async (_args, ctx) => {
			const state = ralphState(ctx);
			const turn = state?.active ? state.turn + 1 : 1;
			ctx.ui.notify(`Ralph started (turn ${turn}/${MAX_TURNS})`, "info");
			await startNextStep(ctx, (session) => {
				session.appendCustomEntry(STATE_TYPE, { active: true, turn } satisfies RalphState);
			});
		},
	});

	pi.on("agent_end", (event, ctx) => {
		const state = ralphState(ctx);
		if (!state?.active) return;

		const marker = finalLine(event.messages);
		if (marker == DONE_MARKER) {
			pi.appendEntry(STATE_TYPE, { ...state, active: false } satisfies RalphState);
			ctx.ui.notify(`Ralph finished after ${state.turn} turn${state.turn == 1 ? "" : "s"}`, "info");
			return;
		}
		if (marker != NEXT_MARKER) return;

		if (state.turn >= MAX_TURNS) {
			pi.appendEntry(STATE_TYPE, { ...state, active: false } satisfies RalphState);
			ctx.ui.notify(`Ralph stopped after ${MAX_TURNS} turns`, "warning");
			return;
		}

		pi.sendUserMessage("/ralph", {
			deliverAs: "followUp",
			expandPromptTemplates: true,
		});
	});
}
