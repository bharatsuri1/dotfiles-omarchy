# Current Omarchy host snapshot

This is the pre-Fedora reference state captured from the running laptop on
2026-08-09. It separates authored, portable behavior from stock Omarchy files,
generated state, and secrets. The package manifests provide the complete
installed-package record; this document records the system relationships that
package names alone cannot reconstruct.

Machine-readable version, theme, plugin-revision, and Herdr checksum anchors
live in `snapshots/current-omarchy-state.env` and are enforced by the repository
audit.

## Baseline identity

- Hardware: Dell XPS 13 DX13260, product/BIOS version `1.3.0`, BIOS dated
  `2026-06-25`, 16 GiB RAM, x86-64.
- OS: Arch Linux with kernel `7.1.4.arch1-1`.
- Omarchy: release `3.8.4`, source revision
  `edce5809df36003c96822b456f327fa79ec1cfd7` (`v3.8.4-4-gedce5809`). The
  upstream source tree was clean at capture time.
- Session: SDDM autologin into the `omarchy` UWSM session; Hyprland `0.56.0`
  on Wayland; system default target `graphical.target`.
- Shell: `/usr/bin/zsh` is the account login shell. `ZDOTDIR` is
  `~/.config/zsh`.
- Locale/time: `en_US.UTF-8`, US console/X11 layout, timezone
  `America/Los_Angeles`, synchronized UTC hardware clock.

The hostname and username are installation inputs, not portable defaults. The
captured host happened to use `omarchy` and `lazyturtle`; restoration must not
hard-code either value.

## Hardware and working drivers

The detailed acceptance commands and PCI inventory are in
[hardware-preflight.md](setup/hardware-preflight.md). The observed working
bindings are:

- Intel Core 5 320 CPU with `intel-ucode` `20260512-1`;
- Wildcat Lake graphics `8086:fd80` on `xe`;
- Intel Wi-Fi `8086:4d40`, subsystem `8086:4314`, on `iwlwifi` with firmware
  `bz-b0-wh-b0-c102.ucode` API 102 from `linux-firmware-intel` `20260622-1`;
- Intel Bluetooth `8086:4d76` on `btintel_pcie`;
- Intel audio `8086:4d28` on `sof-audio-pci-intel-ptl`, SOF firmware
  `2.14.1.1`;
- Kioxia EG6 512 GB NVMe; and
- LG 2560x1600 internal display at 120 Hz and scale 2, touchpad, touchscreen,
  laptop keyboard, battery, and lid switch.

## Disk and boot state

The current Arch system uses one 2 GiB FAT32 `/boot` partition and one LUKS2
partition containing Btrfs. Btrfs uses `@`, `@home`, `@pkg`, and `@log`
subvolumes with `compress=zstd:3`. It has a 15.2 GiB Btrfs swapfile configured
for resume plus a 4 GiB zram device using zstd. Limine, Snapper synchronization,
Plymouth, and mkinitcpio are installed. The current initramfs uses the classic
`encrypt` hook and the kernel command line carries the encrypted-root,
Btrfs-subvolume, resume-offset, quiet-boot, and Plymouth settings.

UUIDs, partition IDs, resume offsets, serial numbers, and encrypted-volume
metadata are deliberately not tracked: a reinstall must derive them from the
new disk. The Fedora v1 design also intentionally differs by using zram without
the Arch swapfile.

## Desktop behavior

- Active stock theme: `catppuccin`.
- Active stock background: Catppuccin `2-waves.png`.
- Hyprland uses its scrolling layout with one-pixel gaps, US layout,
  Caps-as-Escape, 40 Hz repeat, natural scrolling, clickfinger behavior,
  three-finger drag, and touchpad scroll factor `0.4`.
- Idle locks after 600 seconds; suspend locks first and wakes the display after
  resume. Fingerprint unlock is disabled.
- Alacritty is the preferred terminal through `xdg-terminal-exec`. The tracked
  override uses JetBrains Mono Nerd Font at 9 pt, 14 px padding, OSC 52, and
  explicit Shift/Alt-Shift Return CSI-u sequences for tmux and TUIs.
- Zen is the default browser for HTML and HTTP(S); Nautilus is the directory
  handler; Neovim is the default editor and text-file handler.
- The tracked Hyprland bindings launch Alacritty, tmux, Herdr, Zen, Nautilus,
  Spotify/cliamp, Neovim, lazydocker, Signal, Obsidian, Typora, 1Password, and
  the selected web applications.
- The GTK interface uses dark Adwaita, `Yaru-purple` icons, and text scale
  `0.95`. Those values are set by Omarchy first-run/theme commands rather than
  by an authored dconf dump.
- Current Nautilus bookmarks are Downloads, Projects, Pictures, and Videos.

The complete `~/.config/nvim` tree exactly matched
`/etc/skel/.config/nvim` from `omarchy-nvim 2026.7.17-1`; it is upstream and is
restored with `omarchy-nvim-setup`, not vendored. Waybar, Walker, SwayOSD,
Hyprlock, Hyprsunset, UWSM, Foot, Ghostty, Kitty, btop, fastfetch, imv,
Wiremix, font defaults, and the Bluetooth WirePlumber rule also matched stock
Omarchy material. Typora's themes, OpenCode's base configuration, Chromium and
Obsidian flags, and Xournal++ settings also matched Omarchy. Qalculate's saved
defaults and application window state are generated preferences. Their omission
from Git is deliberate.

## Packages and secondary sources

At capture time the deterministic manifests contained:

- 1,014 installed packages with versions;
- 183 explicit packages: 182 from configured sync repositories and one foreign
  package, `zen-browser-bin`;
- three orphan candidates: `clang20`, `lld20`, and `minisign`; and
- Omarchy's stable Pacman repository and mirror in addition to Arch core,
  extra, and multilib.

The names-only manifests are restoration inputs. The versioned manifest is an
audit snapshot, since rolling repositories may no longer publish those exact
versions. The current host includes Docker and Docker Compose because they are
part of the Omarchy reference host; the Fedora v1 design deliberately selects
Podman instead.

Homebrew owns only `dashlane/tap/dashlane-cli`; `node@22` and
`python-setuptools` are formula dependencies rather than declared leaves. Mise
owns Node `26.5.0`. Herdr `0.8.0` is the only direct upstream binary intentionally
kept in `~/.local/bin`; its captured SHA-256 was
`b872ea7e40fa2cb17e857ac9b62b1bf26db7b403c622f5d2f3f5b35f6e9acd28`.
The other local-bin entries are stock Omarchy npm-on-Mise launchers and are
recreated by Omarchy.

No Flatpak applications or user remotes were installed. No VS Code executable
or VS Code extension profile was present on this Arch host.

## Services and integration

Enabled system services include SDDM, iwd plus systemd-networkd/resolved,
Bluetooth, PipeWire prerequisites, CUPS/Avahi, thermald,
power-profiles-daemon, UFW, time synchronization, Limine/Snapper integration,
and on-demand Docker through `docker.socket`.

Enabled user integration includes Walker/Elephant search, SwayOSD, Voxtype,
PipeWire/PulseAudio/WirePlumber, GNOME Keyring, portals, user directories, the
internal-monitor recovery unit, and the Omarchy battery timer. Only
`voxtype.service` is an authored unit tracked here; the rest are generated by
the matching Omarchy installation. The live `voxtype.service` mirror matched
Git exactly.

Omarchy also generated these system policies: Docker's bounded logs and
on-demand socket, Docker DNS through systemd-resolved, AC-only plocate updates,
five-second user shutdown timeout, zstd zram, SDDM Wayland/autologin, and the
standard firewall. They are recorded here but not copied across distributions.

## Portable files captured

The repository mirrors every selected authored file relative to `$HOME`:

- Bash, Zsh, Starship, Atuin, tmux, Git, Mise, Herdr, and Voxtype;
- Alacritty, Hyprland behavior/bindings, Fcitx 5, MIME defaults, and XDG user
  directories;
- `.XCompose` identity shortcuts plus Omarchy's emoji compose include;
- the Voxtype user unit; and
- curated Zen preferences, shortcuts, theme metadata, and CSS.

Every direct mirror matched the live host at capture time. The two Zsh plugin
repositories are intentionally excluded and pinned in the main README.

## Excluded state and secrets

Never commit NetworkManager/iwd credentials, 1Password or Dashlane sessions,
GNOME Keyring contents, SSH/GPG keys, GitHub authentication, browser profiles,
cookies, history databases, Atuin keys/history, shell histories, Herdr sessions
or logs, Pulse cookies, application caches, sockets, lock files, or Neovim's
downloaded plugin data. Zen's curated files are copied individually into the
active profile; its whole profile is never mirrored.

Application window sizes, recent files, caches, telemetry, generated desktop
visibility entries, and stock Omarchy theme trees are also excluded. Disk Usage
and Docker TUI launchers are stock and are reconstructed by Omarchy's
`install/packaging/tuis.sh`, including their icons.

## Reconstruction and proof

Use the [main restore procedure](../README.md#restore) on the matching Omarchy
release, then run:

```bash
.agents/skills/maintain-omarchy-dotfiles/scripts/audit.sh
hyprctl reload
hyprctl configerrors
brew bundle check --file ./Brewfile --no-upgrade
```

Success requires byte-for-byte direct mirrors, matching package manifests,
valid shell and systemd syntax, no Hyprland configuration errors, the selected
theme/default applications, enabled services, and the hardware checks in
[hardware-preflight.md](setup/hardware-preflight.md). Authentication and personal application data must be
restored through their own secure sign-in or backup flows.
