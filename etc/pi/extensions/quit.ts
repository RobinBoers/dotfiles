import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.on("input", (event, ctx) => {
		if (event.text.trim() !== ":q") return { action: "continue" };

		ctx.shutdown();
		return { action: "handled" };
	});
}
