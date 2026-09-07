import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { basename } from "node:path";

const title = (ctx: ExtensionContext) => `Pi @ ${basename(ctx.cwd)}`;

export default function (pi: ExtensionAPI) {
	const notify = (ctx: ExtensionContext, message: string, urgent = false) =>
		pi.exec("notify", [...(urgent ? ["-u"] : []), "-t", title(ctx), message]);

	pi.on("ui_prompt_start", (event, ctx) =>
		notify(ctx, event.title || "Pi needs your attention.", true),
	);

	pi.on("agent_settled", (_event, ctx) =>
		notify(ctx, "Pi is done, take a look."),
	);
}
