import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { readFileSync } from "node:fs";
import { dirname } from "node:path";

const REFERENCE_PATTERN = /(?<![\\\w$])\$([A-Za-z0-9][A-Za-z0-9_-]*)/g;

type Skill = {
	name: string;
	description?: string;
	path: string;
};

function skills(pi: ExtensionAPI): Skill[] {
	return pi
		.getCommands()
		.filter((command) => command.source == 'skill')
		.map((command) => ({
			name: command.name.slice("skill:".length),
			description: command.description,
			path: command.sourceInfo.path,
		}));
}

function stripFrontmatter(content: string): string {
	return content.replace(/^---\r?\n[\s\S]*?\r?\n---(?:\r?\n|$)/, "").trim();
}

type LoadedSkill = Skill & {
	body: string;
};

function loadSkill(skill: Skill): LoadedSkill {
	return { ...skill, body: stripFrontmatter(readFileSync(skill.path, "utf8")) };
}

function expandSkills(skills: LoadedSkill[]): string {
	if (skills.length == 1) {
		const skill = skills[0];
		return `<skill name="${skill.name}" location="${skill.path}">\nReferences are relative to ${dirname(skill.path)}.\n\n${skill.body}\n</skill>`;
	}

	const body = skills
		.map((skill) => {
			const instructions = skill.body.replace(/^# [^\n]+\n+/, "");
			return `## ${skill.name}\n\nLocation: ${skill.path}\n\nReferences are relative to ${dirname(skill.path)}.\n\n${instructions}`;
		})
		.join("\n\n---\n\n");
	const names = skills.map((skill) => skill.name).join(", ");

	return `<skill name="${names}" location="multiple">\n${body}\n</skill>`;
}

export default function (pi: ExtensionAPI) {
	pi.on("input", (event, ctx) => {
		if (event.source == 'extension') return { action: "continue" };

		const available = new Map(skills(pi).map((skill) => [skill.name, skill]));
		const referenced = [...event.text.matchAll(REFERENCE_PATTERN)]
			.map((match) => available.get(match[1]))
			.filter((skill): skill is Skill => !!skill);
		const unique = [...new Map(referenced.map((skill) => [skill.name, skill])).values()];
		if (unique.length == 0) return { action: "continue" };

		const loaded = unique.flatMap((skill) => {
			try {
				return [loadSkill(skill)];
			} catch (error) {
				const message = error instanceof Error ? error.message : String(error);
				ctx.ui.notify(`Could not load $${skill.name}: ${message}`, "error");
				return [];
			}
		});
		if (loaded.length == 0) return { action: "continue" };

		return { action: "transform", text: `${expandSkills(loaded)}\n\n${event.text}` };
	});

	pi.on("session_start", (_event, ctx) => {
		ctx.ui.addAutocompleteProvider((current) => ({
			triggerCharacters: ["$"],
			async getSuggestions(lines, cursorLine, cursorCol, options) {
				const beforeCursor = (lines[cursorLine] ?? "").slice(0, cursorCol);
				const match = beforeCursor.match(/(?:^|[^\\\w$-])\$([a-z0-9-]*)$/);
				if (!match) return current.getSuggestions(lines, cursorLine, cursorCol, options);

				const prefix = `$${match[1]}`;
				const items = skills(pi)
					.filter((skill) => skill.name.startsWith(match[1]))
					.map((skill) => ({
						value: `$${skill.name}`,
						label: `$${skill.name}`,
						description: skill.description,
					}));

				return items.length > 0 ? { prefix, items } : null;
			},
			applyCompletion(lines, cursorLine, cursorCol, item, prefix) {
				return current.applyCompletion(lines, cursorLine, cursorCol, item, prefix);
			},
			shouldTriggerFileCompletion(lines, cursorLine, cursorCol) {
				return current.shouldTriggerFileCompletion?.(lines, cursorLine, cursorCol) ?? true;
			},
		}));
	});
}
