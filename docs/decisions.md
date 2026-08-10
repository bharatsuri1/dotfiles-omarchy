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

All directions use official ISO installation media:

- Arch uses the official Arch ISO, `iwctl` when Wi-Fi setup is needed, guided `archinstall`, and a reboot into a minimal working TTY;
- Fedora Server uses the official Server DVD ISO and its installer, then reboots into a non-graphical base;
- Fedora Workstation uses the official Workstation Live ISO and its graphical installer, then reboots into GNOME.

The Fedora Server Network Install ISO is not the selected path. Niri, DMS, development tools, and personal applications are installed only after the base operating system has booted successfully.

### Installation identity and localization

- Prompt for the hostname and username during installation; do not encode either value in this repository.
- Use `en_US.UTF-8`, the US console/keyboard layout, and `America/Los_Angeles` unless explicitly overridden during installation.
- Enable automatic network time synchronization.
- Give the created human user administrative access through the distribution's `wheel` group; do not enable routine direct-root login.

The current Omarchy storage design is not the v1 baseline. LUKS, Btrfs subvolumes, snapshots, hibernation, Secure Boot, and custom recovery integration are later enhancements rather than bootstrap requirements.

### Filesystem

- Arch, Fedora Server, and Fedora Workstation all use Btrfs.
- Prefer each installer's generated Btrfs layout instead of manually designing subvolumes during bootstrap.
- Custom subvolume schemes, Snapper, bootable rollback entries, and snapshot retention are not part of v1.
- Compression and mount-option details remain to be confirmed from the installer-generated configuration rather than duplicated blindly across distributions.

### Partitioning and encryption

- Use automatic whole-disk partitioning on the target laptop in every direction.
- Do not enable LUKS disk encryption in v1.
- Allow each installer to create the required EFI System Partition and Btrfs layout.
- Do not manually size or maintain a separate home partition in v1.
- Disk encryption remains a later security iteration that must be designed together with initramfs, recovery, and unattended boot expectations.

### Bootloader

- Arch uses systemd-boot through `archinstall` on this UEFI laptop.
- Fedora Server and Fedora Workstation retain the Fedora installer-default boot chain.
- Do not replace Fedora's bootloader or add Limine in v1.
- Secure Boot remains deferred rather than being partially configured.

### Swap and hibernation

- Use zram as the only swap mechanism on the laptop's approximately 16 GiB of RAM.
- Do not create a disk swap partition or swapfile in v1.
- Do not configure hibernation or kernel resume parameters in v1.
- Verify the generated zram device, active swap priority, and behavior under memory pressure after installation.

### Installer Wi-Fi prerequisite

Installer networking is a known risk and must be proven before erasing the current system. The laptop exposes Intel network device `8086:4d40`, subsystem `8086:4314`, and currently works with the `iwlwifi` kernel driver plus `linux-firmware-intel`.

Before accepting any Arch or Fedora ISO for installation:

- boot the exact ISO on this laptop without modifying the disk;
- verify the PCI device is visible and bound to `iwlwifi`;
- verify the necessary Intel firmware loads without errors;
- verify `iwctl` or the Fedora installer can scan, authenticate, obtain an address, resolve DNS, and reach package sources;
- prepare a tested USB-tethering or wired-network fallback;
- do not begin destructive installation if the live environment cannot get online.

The current installation proves a working reference point, not a universal minimum: Arch kernel `7.1.4-arch1-1` with `linux-firmware-intel` `20260622-1` identifies this device as Intel Wi-Fi 7 BE213 160 MHz and loads `iwlwifi-bz-b0-wh-b0-c102.ucode` API 102. Upstream history does not provide enough evidence to claim an older safe minimum for this exact pre-release-generation PCI ID. Therefore the live-ISO functional preflight remains the acceptance test. Prior Fedora and other installer ISOs failed to provide working Wi-Fi on this laptop.

For the August 2026 Fedora installation, use the full Fedora Server 44 DVD rather than its network-install ISO. The 44 release image predates the upstream addition of the exact Bz/Wh `c102` firmware, while current Fedora 44 updates carry newer `iwlwifi-mld-firmware`. A tested USB-tether or wired connection therefore bootstraps the first kernel/firmware update; native Wi-Fi must pass after reboot before the desktop packages are installed.

### Kernel, microcode, and firmware

- Arch uses the standard `linux` kernel.
- Fedora uses its distribution-default kernel.
- Install Intel CPU microcode and the current distribution firmware set, including Intel firmware.
- Do not install an LTS, custom, real-time, hardened, or performance-tuned kernel in v1.
- Validate kernel driver binding and firmware loading for graphics, Wi-Fi, Bluetooth, audio, NVMe, input, battery, and lid after first boot.

### Intel graphics

- Use the kernel `xe` driver selected automatically for Wildcat Lake graphics `8086:fd80`.
- Use Mesa for OpenGL/EGL and the Intel Mesa Vulkan driver.
- Do not install the legacy `xf86-video-intel` Xorg driver.
- Do not add manual graphics kernel parameters without a reproduced hardware problem.
- Do not install 32-bit graphics libraries unless a later selected application requires them.
- Install the Intel VA-API media driver, oneVPL dispatcher/runtime, and VA inspection utility for Wildcat/Panther Lake: Arch uses `vpl-gpu-rt` (which pulls the Intel media driver) plus `libva-utils`; Fedora uses `intel-vpl-gpu-rt`, `libva-intel-media-driver`, and `libva-utils`.
- Verify the selected stack with `vainfo` and real browser/video decode after installation; package presence alone does not prove hardware acceleration.

The current machine proves that kernel `7.1.4-arch1-1` plus `linux-firmware-intel` `20260622-1` loads the Wildcat/Panther Lake DMC, GuC, HuC, and GSC firmware under `xe`. Omarchy's Intel media-acceleration name detection did not match `Wildcat Lake [Intel Graphics]`, so its missing media packages are corrected explicitly rather than copied blindly.

### Input and keyboard remapping

- Use standard kernel HID/input drivers and libinput.
- Let niri or GNOME own touchpad, mouse, natural-scrolling, tap-to-click, and gesture preferences.
- Do not install Xorg input drivers or a separate gesture daemon.
- Use keyd as the only low-level keyboard-remapping daemon.
- Arch installs keyd from Extra. Fedora enables the community `alternateved/keyd` COPR linked by keyd upstream, then installs it through DNF; inspect the repository and transaction before accepting it.
- Required keyd behavior includes Caps Lock as Escape when tapped and a Hyper modifier when held.
- Keep physical-key transformation in keyd and application/window-manager actions in niri, DMS, GNOME, tmux, editors, or applications; do not implement the same transformation in multiple layers.
- Preserve a TTY/recovery path and validate the keyd configuration before enabling it persistently so a bad mapping cannot prevent login.

## Networking

- Use NetworkManager as the single persistent owner of Wi-Fi, Ethernet, DHCP, routes, DNS integration, saved connections, and future VPN profiles across Arch and Fedora.
- Use `nmcli` for terminal control and DMS or GNOME for graphical control.
- Arch installation media may use `iwctl` to get online before `archinstall`; that does not select standalone iwd for the installed system.
- Do not simultaneously enable standalone iwd, systemd-networkd, another network manager, or another DHCP client for interfaces managed by NetworkManager.
- Installer support for the Intel `8086:4d40` device remains a kernel/firmware preflight issue independent of NetworkManager.
- Validate Wi-Fi scanning, authentication, reconnection, suspend/resume, Ethernet, DHCP, routes, DNS, and DMS/GNOME status after installation.

## Bluetooth

- Use BlueZ as the system Bluetooth backend and include its command-line utilities.
- Use DMS Bluetooth controls in niri sessions and GNOME Bluetooth controls in Fedora Workstation.
- Use PipeWire and WirePlumber for Bluetooth audio profiles and routing.
- Do not install Blueman or another Bluetooth GUI in v1.
- Do not enable OBEX or Bluetooth file-transfer services in v1.
- Validate adapter power, discovery, pairing, trusted-device reconnection, suspend/resume, and headset profile switching on the Intel `8086:4d76` controller.

## Audio

- Use PipeWire as the media server and WirePlumber as its session/policy manager.
- Include PipeWire's PulseAudio compatibility and ALSA integration.
- Use DMS audio controls in niri sessions and GNOME audio controls in Fedora Workstation.
- Do not run a separate PulseAudio daemon.
- Do not install JACK compatibility unless a later development workload requires it.
- Do not install a standalone graphical mixer in v1.
- Validate Intel SOF speakers, microphone, headphone output, browser capture/playback, volume keys, suspend/resume, and Bluetooth headset profiles.

## Session and login

- Arch+niri and Fedora Server+niri directions use a TTY login followed by an explicit `niri-session` command.
- The niri+DMS directions use the same TTY login; DMS starts within the validated niri user-session lifecycle.
- Fedora Workstation retains GDM and its normal GNOME session.
- Do not install greetd, SDDM, or another custom greeter in v1.
- Do not automatically launch niri from `.zprofile`, `.zlogin`, or another shell startup file in v1.
- Preserve TTY access as the primary recovery path when niri, DMS, portals, or user services fail.
- Validate clean login, explicit launch, logout back to TTY, environment import, user services, and session shutdown.

## Niri and DMS lifecycle

- Use the distribution-packaged niri session integration and launch it with `niri-session`.
- In niri+DMS directions, attach DMS to niri through the systemd user dependency created by `systemctl --user add-wants niri.service dms`.
- Do not also add `spawn-at-startup "dms" "run"` to niri configuration.
- Let systemd provide DMS start/stop ordering, restart behavior, and user-journal diagnostics.
- Niri-only learning directions omit DMS and its dependency; their individual shell components will be selected and documented separately when those guides are built.
- Remove niri's default Waybar startup when DMS owns the bar, and do not install/start other DMS-overlapping shell daemons.
- Validate exactly one DMS process, one bar, one notification daemon, clean restart, and clean shutdown with the niri session.

### DMS v1 package and feature boundary

Install only the packages and features required for the selected integrated shell.

Arch core:

- `niri`;
- `dms-shell-niri`, which selects the niri compositor integration;
- `dms-shell`, Quickshell, `dgop`, and `accountsservice` as dependencies of the current official Arch package;
- the separately selected Alacritty, `xwayland-satellite`, portals, NetworkManager, BlueZ, PipeWire/WirePlumber, GNOME Keyring/libsecret, polkit, and desktop defaults.

`dgop` and `accountsservice` are accepted because current Arch `dms-shell` packaging requires them, not because every monitoring/profile feature is independently required. Reevaluate them only if upstream packaging makes them optional; do not replace official package dependency resolution with partial manual file installation.

Fedora core:

- enable the upstream-maintained `avengemedia/dms` COPR and install its packaged `niri` and `dms` through DNF;
- treat DNF as the sole owner of both packages and accept their required RPM dependencies;
- inspect the COPR repository configuration, signing-key prompt, enabled Fedora release/architecture, package versions, and proposed transaction before installation;
- do not run the DMS universal installer or combine COPR packages with manually copied DMS release binaries/source;
- preserve the same user-facing feature boundary as Arch even if RPM package decomposition differs;
- update through the normal DNF workflow; removal must uninstall the selected packages and disable the COPR if no remaining package uses it;
- record the exact dependency tree and transaction in the Fedora guide before publishing final install commands.

Explicitly excluded from v1:

- `cava` and audio-visualizer widgets: decorative, not required for audio control or playback;
- `matugen` and wallpaper-derived application theme generation: theming automation is not required to enter or operate the desktop;
- `dsearch` and indexed filesystem search: background indexing and its database are unnecessary for the initial launcher;
- DankCalendar and calendar-account integration: productivity integration is outside the development-machine core;
- optional Qt multimedia sound-feedback packages and UI sound effects: not required for PipeWire audio or notifications;
- third-party DMS plugins and plugin registry additions: defer until a specific missing capability is demonstrated;
- optional weather, external account, printer, monitor-DDC, fingerprint, and other companion integrations unless selected later.

Required v1 DMS behavior is limited to the integrated bar/status surface, application launcher, notifications, lock/idle UI when its power policy is later selected, OSD and basic system controls, wallpaper/background surface, polkit agent, settings, and niri integration. A required package may expose additional features; leave unneeded features disabled and do not install their optional providers.

Validation:

- inspect the native package dependency tree and record it in the platform guide;
- run DMS diagnostics and distinguish required failures from intentionally missing optional providers;
- confirm the shell starts without optional companions and does not repeatedly log failed provider launches;
- confirm launcher, bar, notifications, polkit prompt, network/audio/Bluetooth status, settings, and session shutdown;
- confirm there is no file indexer, calendar sync, visualizer, plugin service, or sound-feedback process running;
- document how to add each optional companion later without rebuilding the base system.

## X11 compatibility

- Install `xwayland-satellite` for the niri directions.
- Let niri create X11 sockets and start the satellite on demand; do not manually start it or set `$DISPLAY`.
- Prefer native Wayland through toolkit/application configuration while retaining X11 fallback for required legacy clients.
- Do not install or expose a separate Xorg desktop session.
- Fedora Workstation retains the Xwayland compatibility supplied by its normal GNOME installation.
- Record applications that actually use Xwayland so the bridge can be reevaluated later.
- Validate at least one known X11 client, native Wayland clients, scaling, clipboard transfer, and clean satellite teardown.

## Desktop portals

- Niri directions install `xdg-desktop-portal`, `xdg-desktop-portal-gnome`, and `xdg-desktop-portal-gtk`.
- Use the GNOME backend for niri-compatible screen capture and the GTK backend as the general fallback where selected by portal configuration.
- Do not install competing KDE, wlroots, or Hyprland portal backends in the niri profiles.
- Fedora Workstation retains its normal GNOME portal configuration.
- Let `niri-session` start the graphical target and D-Bus environment needed by portal services.
- Validate Zen screen sharing, file-open/save dialogs, URI opening, screenshots, and any selected Flatpak application.

## Secret Service and keyring

- Install GNOME Keyring and `libsecret` across all desktop directions.
- Use GNOME Keyring as the Freedesktop Secret Service for VS Code, NetworkManager, Dashlane CLI where applicable, and other credential consumers.
- Fedora Workstation retains its normal GNOME login/keyring integration.
- For TTY-launched niri sessions, design and validate authenticated keyring startup/unlock explicitly.
- Do not copy Omarchy's passwordless default-keyring mechanism, which is designed around its SDDM autologin setup.
- Never store keyring files, unlocked material, authentication state, or exported secrets in this repository.
- Validate Secret Service ownership, lock/unlock behavior, VS Code credential persistence, NetworkManager secrets, and behavior after logout/login.

## Polkit

- Include the standard polkit authorization backend in v1.
- In niri+DMS sessions, DMS is the sole graphical polkit authentication agent.
- In Fedora Workstation, GNOME retains ownership of the authentication-agent UI.
- Do not start a second standalone polkit agent in either of those sessions.
- Niri-only learning profiles initially use terminal `sudo`; add one standalone graphical agent only when that guide introduces graphical privileged operations.
- Validate a real privileged GUI action, cancellation, incorrect-password handling, and absence of duplicate prompts.

## Development foundation

### Native build toolchain

- Arch installs the standard `base-devel` toolchain group.
- Fedora installs its standard Development Tools group.
- Use the distribution-supported C/C++ compiler, linker, Make, debugger, and related build utilities.
- Do not add an alternate compiler suite, custom system toolchain, or global language SDK without a selected workload.
- Validate by compiling, linking, running, and debugging a minimal native program.

### Language runtime ownership

- Use Mise for selected non-Python runtimes such as Node.js.
- Install Mise from Arch's official repository through pacman and from the upstream `jdxcode/mise` COPR through DNF on Fedora.
- The native package manager is the sole owner of Mise; do not install its standalone binary or run `mise self-update`.
- Use uv for Python versions, project virtual environments, dependencies, tools, and lockfiles.
- Install uv from the distribution's native repositories: Arch Extra through pacman and Fedora's repository through DNF.
- The native package manager is the sole owner of the uv executable; do not also install uv through Homebrew, PyPI, Cargo, or Astral's standalone installer.
- Update uv with the full native system update. Do not run `uv self update` for the package-managed executable.
- Do not declare project Python versions in Mise; avoid two tools owning the same Python installation.
- Keep distribution Python under pacman/DNF ownership and never install project packages into it.
- Python projects should declare their Python requirement and use uv-managed `.venv` environments and `uv.lock` where appropriate.
- Install only runtimes required by selected projects; Mise and uv are mechanisms, not permission to preinstall every language.
- Validate Node selection through Mise and a complete uv Python create/sync/run workflow without modifying system Python.

### Containers

- Include Podman as the container runtime across the development-machine directions.
- Prefer rootless containers for normal development work.
- Do not install or enable Docker Engine in v1.
- Do not create a privileged `docker` group or require an always-running system-wide container daemon.
- Keep container images, volumes, credentials, and generated state outside the dotfiles repository.
- Docker CLI compatibility, Quadlet units, and automatic container startup remain outside v1; the Compose provider is selected below.
- Validate rootless image pull, build, run, port publication, bind mounts, stop/removal, and cleanup.

### Compose workflow

- Include `podman compose` for Compose-compatible development projects.
- Install the native `podman-compose` package through pacman on Arch and DNF on Fedora; it is the sole external Compose provider.
- Let `podman compose` discover and invoke `podman-compose`; do not install Docker Compose or override the provider unless a tested project demonstrates an incompatibility.
- Keep `podman` and `podman compose` explicit in commands and documentation.
- Do not create a global `docker` alias or silently claim complete Docker behavior.
- Do not install `podman-docker` in v1.
- Validate a representative multi-container project, networks, volumes, environment handling, logs, shutdown, and cleanup.

## Laptop power boundary

- Keep v1 power configuration minimal and retain distribution/systemd defaults rather than introducing a custom policy stack.
- Do not install TLP, auto-cpufreq, custom sleep hooks, hibernation support, or custom idle/lock/suspend timers in v1.
- Validate manual suspend/resume, installer-default lid-close behavior, battery reporting, and brightness keys without overriding their defaults.
- Fedora Workstation retains the power components supplied by GNOME; do not duplicate them with custom services.
- Detailed ownership, timeouts, AC-versus-battery behavior, power profiles, and DMS idle/lock automation are deferred.

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
- Install herdr with its upstream installer into `~/.local/bin/herdr`; do not also install it through Homebrew, a distribution package, or another manager.
- The installer supports `x86_64` and `aarch64`, obtains the current release metadata and binary over HTTPS, verifies the binary against the SHA-256 value in that metadata, and does not require root or edit shell configuration.
- Treat the checksum as download-integrity protection, not independent publisher verification, because the release URL and checksum arrive through the same unsigned metadata endpoint. Record the installed version and installer URL in the setup guide.
- Update this installation explicitly with `herdr update`, and remove it by deleting only `~/.local/bin/herdr` after preserving any wanted user configuration or state.

### Browser

- Zen Browser is the primary browser and default HTTP/HTTPS handler.
- Validate native Wayland rendering, PipeWire WebRTC sharing, portals, downloads, and password-manager integration under niri and GNOME.
- Do not commit browser profiles or private state.
- Install Zen from its official Flathub package across Arch and Fedora.
- Use the Flatpak desktop ID for HTTP/HTTPS and default-browser associations.
- Do not additionally install Zen from AUR, tarball, AppImage, or its home-directory installer.
- Treat filesystem/device permissions as explicit Flatpak permissions and validate development downloads, portals, screen sharing, media, and external protocol handlers.
- Do not install a second browser without a demonstrated compatibility need.

### Editors

- Neovim with LazyVim is the terminal editor.
- Set both `$EDITOR` and `$VISUAL` to `nvim`.
- Microsoft Visual Studio Code is the graphical editor.
- Arch skips VS Code in v1 because Microsoft VS Code is unavailable from the official pacman repositories and manual AUR management is not selected.
- Fedora installs Microsoft VS Code through Microsoft's official RPM repository.
- DNF is the sole owner of VS Code on Fedora. Do not install the VS Code Flatpak or substitute Code OSS.
- Configure VS Code to use GNOME/libsecret credential storage and disable application self-update when the package manager owns updates.
- VS Code on Arch remains a later decision unless an acceptable pacman repository becomes available.
- Do not enable VS Code Settings Sync in v1.
- Keep only a small reviewed extension list and intentional text-based settings/keybindings in the repository.
- Never commit VS Code tokens, account state, caches, or an opaque copied profile.
- These VS Code decisions apply only to Fedora in v1 because Arch skips its installation.

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

- Install Dashlane CLI from Dashlane's official Homebrew tap with `brew install dashlane/tap/dashlane-cli` across Arch and Fedora.
- Homebrew is the sole owner of `dcli`; do not also install an upstream binary, Yarn/source build, or distribution package.
- Update it through the normal Homebrew update/upgrade workflow and remove it with `brew uninstall dashlane/tap/dashlane-cli`.
- Treat CLI authentication state and any local vault/keychain material as private machine state outside GNU Stow and this repository.

### Git identity and GitHub authentication

- Prompt for Git author name and email during setup; do not hardcode either identity in the repository.
- Authenticate GitHub interactively with `gh auth login`.
- Use a per-machine SSH key for Git remotes and prefer SSH remote URLs over HTTPS credential storage.
- Keep private keys and all SSH runtime state under `~/.ssh` and outside GNU Stow.
- Do not configure commit signing in v1; revisit it as a later security enhancement.

## Shared desktop applications

These are defaults, not bootstrap dependencies:

- Nautilus is the graphical file manager and default directory handler.
- mpv is the default local video and audio-file player.
- imv is the default image viewer.
- Evince is the PDF and read-only document viewer.
- No office suite is installed by default.

Nautilus phone access, Samba shares, video thumbnails, GNOME Disks, LocalSend/transcoding actions, and Dropbox integration are optional modules, not core requirements.

## Package policy recorded so far

Package-source priority is:

1. distribution-native repositories through pacman or DNF;
2. a named trusted project/distribution repository only when required, such as Fedora's selected niri/DMS source;
3. Flatpak for a selected graphical application when the native repository does not provide the required application/build;
4. Homebrew for a small, named set of cross-distribution CLI tools not suitably available from native repositories;
5. AUR or a direct upstream release/installer only in rare, documented cases.

Each package has exactly one owner and update path. Do not install the same application through native packages, Flatpak, Homebrew, AUR, and upstream simultaneously. For every exception, record why the native package is unavailable or unsuitable, how authenticity is checked, how updates happen, and how it is removed.

Homebrew uses its official installer and supported Linux prefix, `/home/linuxbrew/.linuxbrew`. It remains approved only for explicitly named formulae and is not a general replacement for pacman or DNF. Dashlane CLI is assigned to Dashlane's official Homebrew tap across distributions. Zen is assigned to its official Flathub package. Fedora installs Microsoft VS Code from Microsoft's official RPM repository through DNF; Arch skips VS Code in v1 rather than using AUR or a manual package workflow. Herdr is a deliberate direct-upstream exception installed at `~/.local/bin/herdr`. uv is distribution-native on both Arch and Fedora. Fedora niri and DMS use the upstream-maintained `avengemedia/dms` COPR under DNF ownership; the universal installer is not used.

Arch installs lazygit from Extra through pacman. Fedora's official repositories do not package lazygit, so Fedora installs the Linux bottle from the official Homebrew formula; Homebrew is its sole owner there. Git and GitHub CLI remain distribution-native on both systems.

JetBrainsMono Nerd Font is native on Arch as `ttf-jetbrains-mono-nerd`. Fedora's native JetBrains Mono package is not Nerd-patched, so Fedora installs the pinned upstream Nerd Fonts `JetBrainsMono.tar.xz` release into the user's font directory after verifying the project-published SHA-256 checksum. This is a documented direct-upstream exception.

`~/.local/bin` is an explicit allowlist, not a general unmanaged installation prefix. On the current system it contains one direct upstream binary, `herdr`, plus shell launchers named `codex`, `copilot`, `gemini`, `ghui`, `opencode`, `pi`, and `playwright-cli`. Those launchers are not self-contained upstream binaries: they select `node@latest` through Mise and resolve their npm packages through `npx`; they also contain Omarchy-specific fallback calls for Bun installation. Reevaluate and reproduce them only if the corresponding tools are selected later. Do not copy them into the minimal setup merely because they exist on the current machine.

## Dotfile deployment

- Use GNU Stow for the shared user configuration.
- Create a dedicated stow-package subtree; do not stow the repository root.
- Organize packages by ownership boundary, such as shell, terminal, Git, niri, DMS, and applications.
- Keep distribution/system installation scripts and documentation outside the stowed subtree.
- Deployment must preflight conflicts, preserve existing files before replacement, and be safely repeatable.
- Do not use Stow to manage secrets, runtime state, caches, browser profiles, keyrings, credentials, or machine-generated files.
- Validate initial deployment, repeated deployment, clean unstow, broken-link detection, and restoration of any preserved pre-existing file.

## User-data backup

- Install `restic` from the native distribution repository.
- Treat the Restic repository destination and credentials as prompted machine inputs rather than repository defaults.
- Retrieve backup credentials from Dashlane without writing resolved secrets to dotfiles, scripts, shell history, or logs.
- Back up user documents and project data separately from this Git repository and its package manifests.
- Require a successful backup and representative test restore before erasing the current installation.
- Document and validate manual backup, snapshot listing, integrity checking, and restore commands before adding automation.
- Do not enable an automatic backup timer in v1.

## Initial niri and DMS configuration

- Begin with upstream niri and DMS defaults, then override only selected applications and confirmed usability requirements needed for the first working desktop.
- Bind Alacritty, Zen Browser, Nautilus, and the DMS launcher.
- Use dynamic workspaces without fixed workspace-to-monitor assignments.
- Rely on automatic monitor discovery and do not commit this laptop's output identifier in the baseline.
- Keep Caps Lock tap/hold transformation entirely in keyd.
- Use the DMS default wallpaper initially.
- Do not add custom animations, elaborate theming, custom idle timers, or lock automation in v1.
- Treat the opinionated modern visual design as a deliberate post-installation phase. It will cover layout, motion, typography, colors, wallpaper, shell surfaces, interaction details, and hardware-specific display behavior after the baseline is validated on the real installation.

## Updates

- Use manual, deliberate full-system updates rather than unattended upgrades.
- Arch updates with `sudo pacman -Syu`; do not perform partial Arch upgrades.
- Fedora updates with `sudo dnf upgrade --refresh`.
- Update each selected secondary source explicitly: Flatpak, Homebrew, Mise runtimes, uv-managed tools, herdr with `herdr update`, and named external repositories as applicable.
- Review errors before rebooting and do not hide failures inside a single opaque update script.
- Reboot after kernel, firmware, graphics, or critical system-library changes.
- Run the documented hardware, desktop-session, network, audio, portal, editor, and container smoke tests after relevant updates.
- Record package-source ownership so an application is never updated by two managers.

## Recovery model

- Attempt recovery from a TTY first using systemd and user journals, service status, configuration validation, and package-manager repair.
- Keep a verified official installation ISO available as rescue media.
- Use the ISO to mount the Btrfs installation and chroot for bootloader, package, account, network, or configuration repair.
- Use this Git repository and GNU Stow to reconstruct managed user configuration.
- Maintain package manifests sufficient to reconstruct selected native and secondary-source tools.
- Treat user-data backup as separate from dotfiles and package manifests; no private data is implied recoverable from this repository.
- Accept full reinstallation as the last-resort v1 recovery path.
- Do not add snapshot rollback, bootable snapshots, or a custom recovery partition in v1.
- Test the documented mount/chroot path and Stow reconstruction before relying on them.

## Decision discipline

For each remaining category, record:

1. required behavior;
2. selected component;
3. why it was selected;
4. rejected alternatives;
5. packages, services, and configuration it owns;
6. validation proving it works;
7. recovery or removal path.
