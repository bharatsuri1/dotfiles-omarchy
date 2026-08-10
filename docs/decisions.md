# Setup decision ledger

This is the source of truth for choices explicitly finalized during design. An omitted component is not implicitly approved.

## Scope and architecture

### Target machine

V1 targets only the current Dell Intel laptop. It may directly assume the detected Intel Core 5 320 CPU, Intel microcode, Wildcat Lake graphics with the `xe` driver, `iwlwifi`, `btintel_pcie`, Intel SOF audio, Kioxia NVMe storage, built-in display, keyboard, touchpad, battery, and lid. Multi-host abstractions and alternate hardware branches are deferred.

### Learning and setup directions

Maintain these six high-level directions:

1. Arch base.
2. Arch + niri.
3. Arch + niri + DMS.
4. Fedora Server + niri.
5. Fedora Server + niri + DMS.
6. Fedora Workstation + GNOME.

Fedora Workstation remains the simple complete-desktop option and does not install niri or DMS. The two niri-only directions expose individually assembled desktop components for learning. The niri+DMS directions are integrated practical builds.

### Bootstrap direction

The Arch path begins with the Arch ISO, Wi-Fi through `iwctl`, guided `archinstall`, and a reboot into a minimal working TTY. Desktop construction happens after that boundary.

The current Omarchy storage design is not the v1 baseline. LUKS, Btrfs subvolumes, snapshots, hibernation, Secure Boot, and custom recovery integration are later enhancements rather than bootstrap requirements.

### Custom graphical architecture

The custom desktop stack is:

```text
Wayland -> niri -> Quickshell -> DMS
```

- niri owns displays, input, scrolling layout, workspaces, windows, gestures, rules, screenshots, overview, and compositor IPC.
- Quickshell is DMS infrastructure rather than a separately configured user-facing shell.
- DMS is the v1 shell and owns the bar, launcher, notifications, lock/idle UI, OSD, wallpaper, polkit UI, control surfaces, and shell theming.
- Do not start overlapping Waybar, Mako, Fuzzel/Walker, swaylock, swayidle, SwayOSD, wallpaper, notification, or polkit UI services while DMS owns them.
- Backend services remain separate: PipeWire/WirePlumber, networking, BlueZ, portals, logind, and application services.
- Xwayland is retained only as an application compatibility bridge through niri's `xwayland-satellite` integration.

Classic X11 `dwm`, `dwl`, and standalone Quickshell profiles were considered and dropped. DMS remains replaceable in a later iteration after the first working system provides evidence about which shell facilities are actually useful.

## Shared development defaults

### Shell and prompt

- Zsh is the interactive login shell on Arch and Fedora.
- Bash and POSIX `sh` remain the languages for scripts and system tooling.
- Starship is the shared prompt and must render correctly with JetBrainsMono Nerd Font.
- Zsh uses native `compinit` completion with an XDG-located cache.
- Load pinned `zsh-autosuggestions` and `fast-syntax-highlighting` checkouts directly.
- Do not install Oh My Zsh, another shell framework, a plugin manager, or another prompt theme.
- Initialize Atuin and Homebrew when installed.

### Terminal and multiplexers

- Alacritty is the shared terminal and semantic terminal role.
- tmux is the general-purpose local and remote multiplexer.
- herdr is the agent-oriented multiplexer for repository workspaces and agent state.
- Both run inside Alacritty, but routine nesting is not the default because their pane/session features and default `Ctrl-b` prefix overlap.

### Browser

- Zen Browser is the primary browser and default HTTP/HTTPS handler.
- Validate native Wayland rendering, PipeWire WebRTC sharing, portals, downloads, and password-manager integration under niri and GNOME.
- Do not commit browser profiles or private state.
- Flatpak versus upstream installation remains part of the package-source decision.
- Do not install a second browser without a demonstrated compatibility need.

### Editors

- Neovim with LazyVim is the terminal editor.
- Set both `$EDITOR` and `$VISUAL` to `nvim`.
- Microsoft Visual Studio Code is the graphical editor.
- Package source and VS Code extension synchronization remain undecided.

### Font

JetBrainsMono Nerd Font is the primary terminal, editor, Neovim, and shell-glyph font. UI, emoji, and CJK fallbacks may be added only where required.

### Modern CLI baseline

Install:

- Zoxide;
- bat;
- btop;
- fzf;
- ripgrep (`rg`);
- fd;
- eza.

Retain standard `cd`, `cat`, `ps`/`top`, `find`, `grep`, and `ls` for scripts, recovery, and portable instructions. Enhanced aliases and functions are interactive-only.

### Git tooling

- Git is the version-control foundation.
- GitHub CLI (`gh`) handles GitHub-specific operations.
- Lazygit is the interactive terminal interface.
- Credentials, tokens, signing keys, and other private material never enter the repository.
- Credential storage and commit signing remain later security decisions.

### Development secrets

Dashlane CLI (`dcli`) is the selected development secret-access tool. It may provide interactive vault access and inject secrets into processes. Never commit its authentication state, exports, resolved secrets, or generated environment files. Its installation and authentication come after the core development system works.

## Shared desktop applications

These are defaults, not bootstrap dependencies:

- Nautilus is the graphical file manager and default directory handler.
- mpv is the default local video and audio-file player.
- imv is the default image viewer.
- Evince is the PDF and read-only document viewer.
- No office suite is installed by default.

Nautilus phone access, Samba shares, video thumbnails, GNOME Disks, LocalSend/transcoding actions, and Dropbox integration are optional modules, not core requirements.

## Package policy recorded so far

Homebrew is approved as a secondary package source, but ownership boundaries among pacman, DNF, Flatpak, Homebrew, and upstream release binaries remain undecided. Prefer a distribution-native package when the final policy says it is sufficiently current and complete; do not infer that rule until the package-source decision is finalized.

## Decision discipline

For each remaining category, record:

1. required behavior;
2. selected component;
3. why it was selected;
4. rejected alternatives;
5. packages, services, and configuration it owns;
6. validation proving it works;
7. recovery or removal path.
