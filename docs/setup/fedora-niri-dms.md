# Fedora Server + niri + DMS

This path starts with the official Fedora Everything network ISO over Ethernet, installs a custom non-graphical Btrfs base, and adds niri plus DMS from the upstream-maintained COPR.

## 1. Accept the installation media

Complete the dedicated [Fedora 44 network and Wi-Fi bootstrap](fedora-wifi-bootstrap.md). Use tested Ethernet for the Everything network installer and select only the custom minimal/non-graphical environment. Do not continue to niri or DMS until native Wi-Fi passes after the first fully updated reboot.

## 2. Install the Fedora base

In the Fedora installer:

- use the internal NVMe with automatic whole-disk allocation;
- explicitly select an installer-generated Btrfs layout; verify `/` is Btrfs in the final storage summary;
- do not enable LUKS;
- choose the custom/minimal base environment and no graphical add-ons; review the package summary for GNOME, KDE, Xfce, or other desktop groups before accepting it;
- enable NetworkManager networking;
- enter hostname and username interactively and make the user an administrator;
- use `en_US.UTF-8`, US keyboard, and `America/Los_Angeles`;
- keep Fedora's installer-default UEFI boot chain;
- use zram only, with no disk swap or hibernation.

If the installer cannot produce an automatic Btrfs layout, stop rather than silently accepting LVM/XFS. Use its guided custom-storage screen to create the standard Btrfs layout, then recheck the final summary.

Reboot into the TTY, complete steps 5 and 6 of the Wi-Fi bootstrap, and verify:

```bash
findmnt -no FSTYPE /
swapon --show
nmcli device status
timedatectl status
```

## 3. Update and enable the required DNF plugins

```bash
sudo dnf upgrade --refresh
sudo dnf install dnf5-plugins
```

The COPR, `config-manager`, and `needs-restarting` commands come from `dnf5-plugins` on current Fedora.

## 4. Enable and inspect the selected repositories

Enable the stable DMS repository, the official Mise COPR, and the keyd COPR linked by keyd upstream:

```bash
sudo dnf copr enable avengemedia/dms
sudo dnf copr enable jdxcode/mise
sudo dnf copr enable alternateved/keyd
dnf repolist --enabled
```

Reject a repository intended for the wrong Fedora release or architecture. Preview the DMS transaction before accepting it:

```bash
dnf repoquery --info niri dms
dnf repoquery --requires --resolve niri dms
sudo dnf install --assumeno niri dms
```

Use the stable `avengemedia/dms` repository, not `avengemedia/dms-git` and not the universal `curl | sh` installer.

## 5. Install the desktop foundation

```bash
sudo dnf install \
  niri dms alacritty xwayland-satellite \
  xdg-desktop-portal xdg-desktop-portal-gnome xdg-desktop-portal-gtk \
  xdg-utils xdg-user-dirs \
  gnome-keyring libsecret polkit \
  NetworkManager NetworkManager-wifi bluez \
  pipewire pipewire-alsa pipewire-pulseaudio wireplumber \
  mesa-dri-drivers mesa-vulkan-drivers \
  intel-vpl-gpu-rt libva-intel-media-driver libva-utils \
  nautilus mpv imv evince \
  flatpak keyd brightnessctl
```

If a package name differs on the selected Fedora release, use `dnf search` and `dnf repoquery --whatprovides` to identify the Fedora-native equivalent; do not substitute an unreviewed installer.

Enable the persistent system services:

```bash
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now bluetooth.service
```

Configure keyd with the same `/etc/keyd/default.conf` and validation in step 5 of [Arch Linux + niri](arch-niri.md).

Fedora's `bluez` package already supplies `bluetoothctl`. Do not add `bluez-tools` or `bluez-obexd`; neither is needed for the selected Bluetooth workflow.

## 6. Install JetBrainsMono Nerd Font

Fedora packages unpatched JetBrains Mono, not the selected Nerd Font. From the
repository root, install the vendored Nerd Fonts v3.5.0 collection for this
user:

```bash
install -d ~/.local/share/fonts/JetBrainsMonoNerd
find assets/fonts/JetBrainsMono -maxdepth 1 -type f -name '*.ttf' \
  -exec install -m 0644 {} ~/.local/share/fonts/JetBrainsMonoNerd/ \;
fc-cache -f
fc-match 'JetBrainsMono Nerd Font'
```

The vendored archive retains the Nerd Fonts release README and SIL Open Font
License in `assets/fonts/JetBrainsMono`.

## 7. Generate and attach DMS

As the normal user:

```bash
dms setup
niri validate
systemctl --user add-wants niri.service dms.service
systemctl --user daemon-reload
```

Inspect for duplicate startup owners:

```bash
grep -R 'spawn-at-startup.*dms\|spawn-at-startup.*waybar' ~/.config/niri || true
```

Remove any such generated/default startup line before the first session. Do not add another notification daemon, bar, launcher, lock daemon, idle daemon, or polkit agent.

## 8. Start and validate the session

From the TTY:

```bash
niri-session
```

Inside the session:

```bash
systemctl --user status niri.service dms.service --no-pager
journalctl --user -u niri -u dms -b --no-pager
dms doctor -v
pgrep -a -f 'dms|quickshell|waybar|mako|swaync'
```

Apply the same DMS, portal, keyring, Xwayland, and hardware exit criteria as the Arch+DMS guide. Do not add custom PAM edits until the stock TTY login and Secret Service behavior have been observed and backed up.

## 9. Continue with the shared environment

Complete [the shared user and development setup](shared-user-environment.md). The Fedora section there also installs Microsoft VS Code through Microsoft's DNF repository.
