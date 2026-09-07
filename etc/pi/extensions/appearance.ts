import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { spawnSync } from "node:child_process";

function output(command: string, args: string[]): string | undefined {
	const result = spawnSync(command, args, {
		encoding: "utf8",
		stdio: ["ignore", "pipe", "ignore"],
		timeout: 500,
	});

	return result.error ? undefined : result.stdout.trim().toLowerCase();
}

function macAppearance(): "light" | "dark" {
	return output("defaults", ["read", "-g", "AppleInterfaceStyle"])?.includes("dark") ? "dark" : "light";
}

function linuxAppearance(): "light" | "dark" | undefined {
	const gtkTheme = process.env.GTK_THEME?.toLowerCase();
	if (gtkTheme) return gtkTheme.includes("dark") ? "dark" : "light";

	const colorScheme = output("gsettings", ["get", "org.gnome.desktop.interface", "color-scheme"]);
	if (colorScheme?.includes("prefer-dark")) return "dark";
	if (colorScheme?.includes("prefer-light")) return "light";

	const gnomeTheme = output("gsettings", ["get", "org.gnome.desktop.interface", "gtk-theme"]);
	if (gnomeTheme) return gnomeTheme.includes("dark") ? "dark" : "light";

	for (const command of ["kreadconfig6", "kreadconfig5"]) {
		const kdeTheme = output(command, ["--group", "General", "--key", "ColorScheme"]);
		if (kdeTheme) return kdeTheme.includes("dark") ? "dark" : "light";
	}

	return undefined;
}

export default function (_pi: ExtensionAPI) {
	if (process.env.PI_APPEARANCE_THEME) return;

	const appearance = process.platform == "darwin"
		? macAppearance()
		: process.platform == "linux"
			? linuxAppearance()
			: undefined;

	if (appearance) process.env.PI_APPEARANCE_THEME = appearance;
}
