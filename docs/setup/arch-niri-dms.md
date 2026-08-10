# Arch Linux + niri + DMS

This is the first practical Arch desktop: the Arch base, niri compositor, and packaged DankMaterialShell/Quickshell integration. DMS is the sole bar, launcher, notification UI, OSD, shell settings surface, lock UI, and polkit agent.

## 1. Install and verify the Arch base

Follow steps 1 through 3 of [Arch Linux + niri](arch-niri.md). Do not install the compositor-only package set from that guide.

## 2. Inspect the selected package boundary

Refresh package metadata and inspect the native packages before installation:

```bash
sudo pacman -Syu
pacman -Si niri dms-shell dms-shell-niri quickshell dgop xwayland-satellite
```

`dms-shell-niri` must resolve to repository packages, not AUR packages. Accept `dms-shell`, Quickshell, `dgop`, and AccountsService as required packaged dependencies. Do not add the optional `cava`, `matugen`, `dsearch`, DankCalendar, or Qt multimedia sound-feedback packages.

## 3. Install the desktop foundation

```bash
sudo pacman -S --needed \
  niri dms-shell-niri alacritty xwayland-satellite \
  xdg-desktop-portal xdg-desktop-portal-gnome xdg-desktop-portal-gtk \
  xdg-utils xdg-user-dirs \
  gnome-keyring libsecret polkit \
  networkmanager bluez bluez-utils \
  pipewire pipewire-audio pipewire-alsa pipewire-pulse wireplumber \
  mesa vulkan-intel vpl-gpu-rt libva-utils \
  nautilus mpv imv evince \
  flatpak ttf-jetbrains-mono-nerd keyd brightnessctl
```

Enable the system services:

```bash
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now bluetooth.service
```

Configure and validate keyd using step 5 of [Arch Linux + niri](arch-niri.md).

## 4. Generate the upstream DMS+niri baseline

Run as the normal user:

```bash
dms setup
niri validate
systemctl --user add-wants niri.service dms.service
systemctl --user daemon-reload
```

`dms setup` only creates missing or empty files. Inspect what it generated:

```bash
find ~/.config/niri -maxdepth 3 -type f -print
grep -R 'spawn-at-startup.*dms\|spawn-at-startup.*waybar' ~/.config/niri || true
```

There must be no direct DMS startup and no Waybar startup in niri configuration. The `niri.service.wants/dms.service` dependency is the single startup owner.

Do not customize the generated DMS appearance yet. Keep dynamic workspaces, automatic output discovery, and the default wallpaper.

## 5. Start the session

From the TTY:

```bash
niri-session
```

Do not install or enable GDM, SDDM, greetd, or a shell-profile auto-launch. DMS should start because niri's user service wants it.

## 6. Validate single ownership

From Alacritty inside niri:

```bash
systemctl --user status niri.service dms.service --no-pager
journalctl --user -u niri -u dms -b --no-pager
dms doctor -v
pgrep -a -f 'dms|quickshell|waybar|mako|swaync'
```

Expected:

- one DMS/Quickshell shell and no Waybar, Mako, SwayNC, or second polkit agent;
- DMS launcher, bar, notifications, settings, audio/network/Bluetooth status, OSD, and polkit prompt work;
- missing optional integrations are reported as optional, without repeated failed-launch loops;
- no file indexer, calendar sync, Cava visualizer, theme generator, or plugin daemon runs.

Validate portals and keyring as described in step 7 of [Arch Linux + niri](arch-niri.md). DMS lock authentication should remain password-only in v1; do not add fingerprint or security-key PAM changes.

## 7. Continue with the shared environment

Complete [the shared user and development setup](shared-user-environment.md).

## 8. Exit criteria

- `niri validate` succeeds;
- explicit TTY launch and logout work;
- systemd starts and stops DMS with niri;
- exactly one shell owns overlapping desktop functions;
- Zen screen sharing/file chooser, Xwayland fallback, audio, Bluetooth, Wi-Fi, polkit, Secret Service, suspend/resume, brightness, and media acceleration pass their smoke tests.
