import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const BLANK = "";
const FALLBACK = "Working...";
const HIGHLIGHT_WIDTH = 6;
const SCROLL_INTERVAL_MS = 70;
const GRAY_STYLE = "\x1b[38;5;238m";
const WHITE_STYLE = "\x1b[97m";
const RESET_STYLE = "\x1b[0m";

function withWorkingSuffix(text: string): string {
	return text.endsWith("...") ? text : `${text}...`;
}

function stripMarkdown(text: string): string {
	return text
		.replace(/!\[([^\]]*)\]\([^)]*\)/g, "$1")
		.replace(/\[([^\]]+)\]\([^)]*\)/g, "$1")
		.replace(/`([^`]*)`/g, "$1")
		.replace(/(\*\*|__)(.*?)\1/g, "$2")
		.replace(/(\*|_)(.*?)\1/g, "$2")
		.replace(/^\s{0,3}#{1,6}\s+/g, "")
		.replace(/^\s{0,3}>\s?/g, "")
		.replace(/^\s*[-*+]\s+/g, "")
		.replace(/^\s*\d+[.)]\s+/g, "")
		.trim();
}

function lastUsefulLine(text: string): string {
	const lines = text
		.replace(/\r/g, "")
		.split("\n")
		.map((line) => stripMarkdown(line))
		.filter(Boolean);

	return lines.at(-1) ?? BLANK;
}

function latestThinking(message: any): string {
	const blocks = Array.isArray(message?.content) ? message.content : [];
	const block = blocks.findLast((entry: any) => entry?.type === "thinking" && entry.thinking?.trim());
	return block ? lastUsefulLine(block.thinking) : BLANK;
}

function branchHasMessages(ctx: { sessionManager: { getBranch(): Array<{ type?: string }> } }): boolean {
	return ctx.sessionManager.getBranch().some((entry) => entry.type === "message");
}

function toolActivity(toolName: string): string {
	const labels: Record<string, string> = {
		bash: "Running command",
		edit: "Editing",
		find: "Finding",
		grep: "Searching",
		ls: "Listing",
		read: "Reading",
		write: "Writing",
	};

	return labels[toolName] ?? `Running ${toolName}`;
}

function blankLine(width: number): string {
	return " ".repeat(width);
}

function fitText(text: string, width: number): string {
	if (width <= 0) return BLANK;

	const chars = Array.from(text);
	if (chars.length <= width) return text.padEnd(width, " ");
	if (width === 1) return "…";

	return `${chars.slice(0, width - 1).join("")}…`;
}

function animatedText(text: string, width: number, offset: number): string {
	const visible = fitText(text, width);
	const chars = Array.from(visible);
	if (!chars.length) return BLANK;

	let activeLength = chars.length;
	while (activeLength > 0 && chars[activeLength - 1] === " ") activeLength -= 1;
	if (!activeLength) return BLANK;

	const highlightWidth = Math.min(HIGHLIGHT_WIDTH, activeLength);
	const highlightHead = offset % (activeLength + highlightWidth - 1);

	return chars
		.map((char, index) => {
			const highlighted = index <= highlightHead && index > highlightHead - highlightWidth && char !== " ";
			return `${highlighted ? WHITE_STYLE : GRAY_STYLE}${char}`;
		})
		.join("") + RESET_STYLE;
}

export default function (pi: ExtensionAPI) {
	let active = false;
	let hasMessages = false;
	let text = BLANK;
	let scrollOffset = 0;
	let scrollTimer: ReturnType<typeof setInterval> | undefined;
	let requestRender: (() => void) | undefined;

	function setText(nextText: string) {
		if (nextText != text) scrollOffset = 0;
		text = nextText;
	}

	function startScrolling() {
		if (scrollTimer) return;
		scrollTimer = setInterval(() => {
			if (!active) return;
			scrollOffset += 1;
			requestRender?.();
		}, SCROLL_INTERVAL_MS);
	}

	function stopScrolling() {
		if (!scrollTimer) return;
		clearInterval(scrollTimer);
		scrollTimer = undefined;
		scrollOffset = 0;
	}

	pi.on("session_start", (_event, ctx) => {
		active = false;
		hasMessages = branchHasMessages(ctx);
		setText(BLANK);
		stopScrolling();
		ctx.ui.setWorkingVisible(false);

		ctx.ui.setWidget(
			"activity-indicator",
			(tui, _theme) => {
				requestRender = () => tui.requestRender();

				return {
					dispose() {
						requestRender = undefined;
					},
					invalidate() {},
					render(width: number): string[] {
						const raw = active ? withWorkingSuffix(text || FALLBACK) : BLANK;
						if (!raw) return [];

						const available = Math.max(0, width - 3);

						return [` ${WHITE_STYLE}·${RESET_STYLE} ${animatedText(raw, available, scrollOffset)}`, blankLine(width)];
					},
				};
			},
			{ placement: "aboveEditor" },
		);
	});

	pi.on("agent_start", () => {
		active = true;
		hasMessages = true;
		setText(FALLBACK);
		startScrolling();
		requestRender?.();
	});

	pi.on("message_start", () => {
		hasMessages = true;
		requestRender?.();
	});

	pi.on("message_update", (event) => {
		const thinking = latestThinking(event.message);
		if (thinking && thinking != text) {
			setText(thinking);
			requestRender?.();
		}
	});

	pi.on("tool_execution_start", (event) => {
		active = true;
		setText(toolActivity(event.toolName));
		startScrolling();
		requestRender?.();
	});

	pi.on("agent_settled", () => {
		active = false;
		setText(BLANK);
		stopScrolling();
		requestRender?.();
	});

	pi.on("session_shutdown", () => {
		active = false;
		stopScrolling();
	});
}
