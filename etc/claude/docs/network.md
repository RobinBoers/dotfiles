# Network

SSH remotes, tailnet, and the servers this account reaches. Hosts
are referenced by their SSH alias or Tailscale name throughout the dotfiles.

## SSH config

Canonical config is `~/etc/ssh/config` (XDG). `~/.ssh/config` is a thin shim
that only `Include`s two files, in order:

```ssh
~/.orbstack/ssh/config   # OrbStack-managed `orb` host for local Linux VMs
~/etc/ssh/config         # the real config — edit this one
```

Global defaults: `AddKeysToAgent yes`, `StrictHostKeyChecking accept-new`.

### Hosts

| Alias                       | User          | Host / IP          | Port | Key          |
|-----------------------------|---------------|--------------------|------|--------------|
| `nov`                       | `axcelott`    | `100.113.201.50`   | 22   | `sweet`      |
| `dec`                       | `axcelott`    | `100.86.248.63`    | 22   | `sweet`      |
| `du`                        | `gitwastaken` | `100.113.201.50`   | 22   | `sweet`      |
| `gh`                        | `git`         | `github.com`       | 22   | `github`     |
| `s11`                       | `robinb`      | `94.124.122.11`    | 22   | `sweet`      |
| `s09`                       | `rboers`      | `94.124.122.9`     | 22   | `sweet`      |
| `cobblestone.11networks.nl` | `axcelott`    | `94.124.124.41`    | 22   | `11networks` |
| `mango.maakotheek.nl`       | `maakadmin`   | (default)          | 3872 | `maakotheek` |
| `maakotheek.nl`             | `maakadmin`   | (default)          | 7158 | `maakotheek` |

`nov` and `du` are the **same machine** (`november`, Tailscale `100.113.201.50`),
just different login users: `nov` for interactive shell, `du` for git over SSH.

Tailscale IPs are in the `100.x.x.x` range. bHosted shared servers are in `94.124.122.x`,
and private servers in `94.124.124.x`.

Keys live in `~/.ssh/`: `sweet` (the main personal key, used for all Tailnet +
the `94.124.122.x` boxes), `github`, `11networks`, `maakotheek`, `solis`.

## Tailscale

Tailnet MagicDNS suffix: `tail0f2a23.ts.net`. Nodes are reachable by short
name (e.g. `november`) when MagicDNS is up, or by their `100.x` CGNAT IP.

### Own devices (`RobinBoers@github`)

| Name        | IP                | OS    | Notes                        |
|-------------|-------------------|-------|------------------------------|
| `november`  | `100.113.201.50`  | linux | Synology NAS                 |
| `moo`       | `100.115.224.82`  | macOS | personal MacBook             |
| `beta`      | `100.112.149.28`  | macOS | work MacHook                 |
| `lambda`    | `100.99.153.109`  | iOS   | iPhone                       |
| `xi`        | `100.127.119.70`  | iOS   | iPad                         |
| `alpha`     | `100.96.70.16`    | linux | ThinkPad (Alpine Linux)      |
| `delta`     | `100.125.196.122` | linux | Beelink (Arch Linux)         |

### Shared devices (other users)

These belong to other people but are visible/reachable on the shared tailnet:

- `Gijs6@github`: `december`, `lithium`, `sodium`.
- `m1kadev@github`: `february` `basil`, `chives`.
- `significant-cijfer@github`: `antegria`, `arstotzka`, `kolechia`.

## Servers, what's what

- **`november`** - my personal server. Reachable as `nov` (shell) or `du` (git).
- **`december`** — server operated by `Gijs6@github`. Reachable as `dec` (shell).
- **`february`** — server operated by `m1kadev@github`. Reachable as `feb` (shell).

All three function as exit nodes.
