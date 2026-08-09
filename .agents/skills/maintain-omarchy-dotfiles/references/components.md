# Component map

Use this map to decide ownership and validation scope. Inspect the filesystem for exact filenames; this map records conventions and non-obvious choices rather than duplicating the repository manifest.

| Component | Live source | Repository form | Ownership / notes |
|---|---|---|---|
| Bash | `~/.bashrc`, `~/.bash_profile` | Same paths | Portable shell setup; Omarchy defaults remain sourced from upstream. |
| Zsh | `~/.zshenv`, `~/.config/zsh/.zshrc` | Same paths | Portable. Keep downloaded plugin repositories out; pin install revisions in restore docs. |
| Starship | `~/.config/starship.toml` | Same path | Portable. |
| Atuin | `~/.config/atuin/config.toml` | Same path | Config is portable; history databases and keys are state/sensitive. |
| Hyprland | `~/.config/hypr/*.conf` | Same paths | Capture authored overrides. Stock files identical to Omarchy need not be tracked. |
| Fcitx 5 | `~/.config/fcitx5/profile`, selected `conf/*.conf` | Same paths | Capture stable preferences; exclude DBus data and cached layouts. |
| Tmux | `~/.config/tmux/tmux.conf` | Same path | Capture when it differs from upstream or encodes restore behavior such as the default shell. |
| Mise | `~/.config/mise/config.toml` | Same path | Runtime declarations are portable; installed runtimes are generated. |
| Herdr | `~/.config/herdr/config.toml` | Same path | Config is portable; logs, sessions, locks, binaries, and managed integrations are generated. |
| Voxtype | Config plus user unit | Same paths | Track config and unit. Document service enablement separately. |
| Git | `~/.config/git/config` | Same path | Identity may intentionally differ between live and public repo. Resolve deliberately. |
| MIME | `~/.config/mimeapps.list` | Same path | Portable default-application mapping. |
| Zen | Active profile selected by `profiles.ini` | Portable files under `.config/zen/` | Track only curated `user.js`, shortcut/theme JSON, and CSS. Never mirror the profile directory. |
| Homebrew | Installed taps/formulae | `Brewfile` | Generate declarative leaves/taps; do not track Cellar or cache. |
| Pacman | Local package database | `packages-*.txt` | Generate with the bundled script. Names-only explicit lists restore; version snapshot diagnoses drift. |
| systemd user | `~/.config/systemd/user/*.service` | Same path | Track authored units. Document enablement; avoid absolute `*.wants` symlinks. |

## Omarchy-managed material

Treat exact matches under these locations as upstream unless a restore reason says otherwise:

- `~/.local/share/omarchy/config/`
- `~/.local/share/omarchy/default/`
- `~/.config/omarchy/current/`

The first two are read-only installation sources. The last is generated current-theme state. Custom themes belong under `~/.config/omarchy/themes/<name>/` as real directories.
