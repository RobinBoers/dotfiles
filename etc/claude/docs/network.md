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
| `oct`                       | `axcelott`    | `100.93.30.19`     | 22   | `sweet`      |
| `nov`                       | `axcelott`    | `100.113.201.50`   | 22   | `sweet`      |
| `dec`                       | `axcelott`    | `100.86.248.63`    | 22   | `sweet`      |
| `feb`                       | `axcelott`    | `100.65.2.1`       | 22   | `sweet`      |
| `du`                        | `gitwastaken` | `100.113.201.50`   | 22   | `sweet`      |
| `gh`                        | `git`         | `github.com`       | 22   | `github`     |
| `cb`                        | `git`         | `codeberg.org`     | 22   | `github`     |
| `s11`                       | `robinb`      | `94.124.122.11`    | 22   | `sweet`      |
| `s09`                       | `rboers`      | `94.124.122.9`     | 22   | `sweet`      |
| `s06`                       | `robinb`      | `94.124.122.6`     | 22   | `sweet`      |
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

### Own devices (`axcelott`)

| Name        | IP                | OS    | Notes                        |
|-------------|-------------------|-------|------------------------------|
| `october`   | `100.93.30.19`    | linux | Beelink (Arch Linux)         |
| `november`  | `100.113.201.50`  | linux | Synology NAS                 |
| `moo`       | `100.115.224.82`  | macOS | personal MacBook             |
| `beta`      | `100.112.149.28`  | macOS | work MacBook                 |
| `lambda`    | `100.99.153.109`  | iOS   | iPhone                       |
| `xi`        | `100.127.119.70`  | iOS   | iPad                         |
| `alpha`     | `100.96.70.16`    | linux | ThinkPad (Alpine Linux)      |
| `delta`     | `100.125.196.122` | linux | Beelink (Arch Linux)         |
| `zeta`      | ??                | linux | Raspberry Pi (Raspbian)      |

The `delta` and `october` devices are a single physical device with tailscaled
running twice, once in kernel-mode and once in userspace-mode.

We have also setup aliases on `*.dupunk.to` using an in-house tool called
`tailmirror`, which creates A-records for devices in our tailnet. The aliases
resolve to the same `100.x` IP range as the `ts.net` hostnames.

For servers two variants exist: `november.dupunk.to` and `nov.dupunk.to`.

### Shared devices (other users)

These belong to other people but are visible/reachable on the shared tailnet:

- `ggijs`: `december`, `helium`, `lithium`, `sodium`.
- `mika`: `february` `basil`, `chives`, `leeks`, `shallot`.
- `pot`: `june`, `antegria`, `arstotzka`, `kolechia`.

## Servers, what's what

- **`november`** - my personal server. Reachable as `nov` (shell) or `du` (git).
- **`october`** - my second server. Reachable as `oct` (shell).
- **`december`** — server operated by `ggijs`. Reachable as `dec` (shell).
- **`february`** — server operated by `mika`. Reachable as `feb` (shell).

All four function as exit nodes.

`october` and `december` function as `lift` builders.
`november` and `december` function as `lift` runners.
