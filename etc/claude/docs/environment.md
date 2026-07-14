# Environment

Critical context about this machine and account. The setup is deliberately
non-standard; agents that assume a conventional layout get things wrong here.
Read this before touching shell config, dotfiles, paths, or git in `~`.

## Home is a git repo (dotfiles)

`~` is itself a git repository with `.gitignore` containing a single `*`.
**Everything is ignored by default.** Files are tracked explicitly:

```sh
git add -f <file>   # the ONLY way to start tracking a dotfile
```

The repo syncs dotfiles to `origin` (`du:meta/dotfiles`). Consequences:

- `git status` in `~` looks clean even though most of home is untracked. That
  is expected, not a sign that nothing exists.
- `git add .` / `git add -A` do nothing useful here (everything is ignored).
- Committing in `~` publishes dotfiles to a remote. Don't commit or push in
  `~` unless explicitly asked.
- A tracked file showing as modified is a real dotfile change worth surfacing.
- Tools like `fd` and `rg` do not work properly in *any* folder, unless
  specified to ignore `.gitignore`.

## XDG layout (non-standard paths)

Config lives in `~/etc`, **not** `~/.config`. Scripts live in `~/bin`, **not**
`~/.local/bin`. Other directories have more standard paths.

| Variable           | Path               | Holds                          |
|--------------------|--------------------|--------------------------------|
| `XDG_CONFIG_HOME`  | `~/etc`            | configuration files            |
| `XDG_BINARY_HOME`  | `~/bin`            | scripts and personal binaries  |
| `XDG_DATA_HOME`    | `~/.local/share`   | persistant state & app data    |
| `XDG_STATE_HOME`   | `~/.local/state`   | volatile state                 |
| `XDG_CACHE_HOME`   | `~/.cache`         | caches                         |

A tool's config is at `~/etc/<tool>`, and its data `.local/share/<tool>`.
It should NOT be at `~/.<tool>`.

Where possible, environment variables in `~/etc/env` are used to configure
tools that do not honour XDG. `~/.config` is symlinked to `~/etc` for
tools that only semi-follow the XDG spec.

## Dual-shell config (bash + zsh)

Both shells share one set of POSIX-`sh` config files, sourced from
shell-specific rc files:

```
~/.bashrc            -> delegates to ~/etc/bash/bashrc
~/.zshenv            -> sets ZDOTDIR=~/etc/zsh
~/etc/zsh/.zshrc     -> the zsh rc
~/etc/bash/bashrc    -> the bash rc

both rc files source, in order:
  ~/etc/env       env vars + exports
  ~/etc/aliases   aliases + shell functions
  ~/etc/profile   PATH and login setup
```

**Edit the shared trio (`env`, `aliases`, `profile`) for anything that should
apply to both shells, and keep it POSIX-compatible** — no bashisms or zsh-isms.

Shell-specific behaviour (completions, plugins etc.) goes in the shell rc file.

## OS targets

This setup moves across four machines: **macOS** (two MacHooks, both Apple Silicon),
**Debian/Raspbian** on a Raspberry Pi, **Alpine Linux** and **Arch Linux**.

Write portable POSIX code; avoid GNU-only flags. Don't depent on folder structure like
`/Users/...` or `/opt/homebrew/...`. Use guards (`uname`) to check the OS where needed.

## PATH precedence

Set in `~/etc/env`, highest priority first:

```
~/bin/$(hostname):~/bin/$(uname):~/bin:<system PATH>:~/.local/bin
```

`~/bin` holds personal scripts; per-host and per-OS subdirs override them.

`~/.local/bin` is last (some tools demand it after installing themselves to
`XDG_BINARY_HOME`, because they only semi-follow the XDG spec).

## Tooling and conventions

- Editor: `EDITOR=hx` (Helix). Edit files with `e <file>` — a sudoedit-style
  wrapper in `~/bin` that escalates only when the file isn't writable. No need
  to add `sudo` manually.
- Version managers: `mise` and `asdf` (Elixir/Erlang/Node). `direnv` for
  per-dir env. `rustup` for Rust.
- Package management: the appropriate package manager for the system is
  automatically aliased as `gimme <packages>`.
- Python venv at `~/.local/share/venv` (`pip install` freely; create with
  `python3 -m venv $XDG_DATA_HOME/venv` if missing).

Other important tools:

- `wt` for git worktrees
- `pass` (password-store at `~/.local/share/passwords`).
  On Linux, unlocked via `keychain`. Used to autofill SSH passphrases using `askpass`.
- `gum` for interactive TUI in scripts.

### `~/bin` helper scripts

Small POSIX helpers used throughout the scripts. Full usage in
`~/etc/claude/docs/shell.md`; the essentials:

- `err <msg>` — print error and exit 1
- `has <cmd>` — check if command is installed
- `required <cmd>` — abort unless `<cmd>` is installed
- `prompt -y "Question?"` — y/n confirmation
- `quiet <cmd>` — suppress all output
- `try <cmd>` — suppress all output and swallow exit code

## Claude

Two personas share one settings file:

- `clawd` — personal
- `qlaude` — work

Each lives at `~/.local/share/claude/<persona>/` and is selected via
`CLAUDE_CONFIG_DIR`. Launch with the `clawd` / `qlaude` aliases, or bare
`claude` for a `gum` persona chooser. Both personas symlink `settings.json`
and `CLAUDE.md` back to `~/etc/claude/`, so shared config has a single source
of truth. Edit the files under `~/etc/claude/`, not the symlinks.

There is a statusline at `~/bin/claude-statusline`. There's documentation for
Claude to reference at `~/etc/claude/docs`, and skills are made available at
`~/etc/claude/skills`.

## Pi agent

Pi agent is configured with `PI_CODING_AGENT_DIR=$XDG_DATA_HOME/pi/agent`, so the agent directory is at `~/.local/share/pi/agent`, not `~/.pi/agent`. This overrides the documented default `~/.pi/agent`.

Do not edit or create `~/.pi`, but use `~/.local/share/pi`.
