# Shell scripting

Read before writing or editing shell scripts. See `environment.md` for the
machine layout (XDG paths, OS targets) these scripts run on.

## Portability

Target POSIX `sh`. The same scripts run on macOS, Debian/Raspbian, and Alpine.
Avoid GNU-only flags and bashisms unless the script explicitly uses a `bash`.
shebang. Prefer portable constructs over GNU coreutils extensions. Also keep
in mind that Alpine uses musl instead of glibc.

## `~/bin` helpers

There's nicities for scripting available in `~/bin`. Prefer them over
reinventing the same logic. Most important are:

- `err <message>` prints `<script>: message` to stderr and exit 1.
  In `-e` mode this aborts the script.
  Example: `err "unsupported option"`.

- `has <command>` returns 0 if `<command>` is in PATH.
  Use instead of the clunky `command -v <command> >/dev/null`.
  Example: `if has pandoc; then ...; fi`.

- `required <command>` declares a dependency at the top of a script.
  Aborts via `err` if missing.
  Example: `required pandoc`.

- `prompt` for y/n confirmation, exit status reflects the answer.
  `-y` makes Yes the default, `-n` makes No the default.
  Example: `if prompt -y "Are you sure?"; then`

## Style

- POSIX `sh` (`#!/bin/sh`) unless bash features are genuinely needed.
- Omit quotes if it doesn't break the program, but be consistent. If quoting
  is needed in one place in a script, apply it everywhere.
- Single quotes for short state/enum-like strings, double quotes for textual
  messages and anything with interpolation.
