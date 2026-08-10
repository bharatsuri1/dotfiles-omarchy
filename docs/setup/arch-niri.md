# Arch Linux + niri

This path is the compositor-learning checkpoint. It boots a minimal Arch base into niri with Alacritty, portals, Xwayland compatibility, networking, audio, Bluetooth, keyring, and polkit foundations. It intentionally does not add DMS, another bar, a launcher, a notification daemon, or lock/idle automation.

## 1. Accept the installation media

Complete [the hardware and network preflight](hardware-preflight.md). Stop if the exact ISO cannot bring this laptop online.

## 2. Install the Arch base

From the connected Arch ISO:

```bash
timedatectl set-ntp true
archinstall
```

Choose these values in the guided installer:

- mirrors: a nearby official region;
- disk: the target internal NVMe, automatic whole-disk layout;
- filesystem: Btrfs using archinstall's generated layout;
- encryption: none;
- bootloader: systemd-boot;
- swap: zram, with no disk swap and no hibernation;
- hostname and user: enter them interactively; add the user as an administrator;
- profile: minimal, with no desktop profile;
- kernel: `linux` only;
- networking: copy the ISO network configuration or select NetworkManager;
- audio: PipeWire if archinstall offers it;
- timezone: `America/Los_Angeles`;
- locale: `en_US.UTF-8`, US keyboard;
- additional packages: `intel-ucode linux-firmware linux-firmware-intel networkmanager sudo zsh`.

Review the generated configuration before confirming. The disk summary must say Btrfs and unencrypted. Install, reboot, and log in on the TTY.

## 3. Verify the base before adding a desktop

```bash
findmnt -no FSTYPE /
swapon --show
bootctl status
nmcli device status
timedatectl status
```

Stop and correct the base if `/` is not Btrfs, disk swap exists, or NetworkManager does not own the network.

## 4. Update and install the niri foundation

```bash
sudo pacman -Syu
sudo pacman -S --needed \
  niri alacritty xwayland-satellite \
  xdg-desktop-portal xdg-desktop-portal-gnome xdg-desktop-portal-gtk \
  xdg-utils xdg-user-dirs \
  gnome-keyring libsecret polkit \
  networkmanager bluez bluez-utils \
  pipewire pipewire-audio pipewire-alsa pipewire-pulse wireplumber \
  mesa vulkan-intel vpl-gpu-rt libva-utils \
  nautilus mpv imv evince \
  flatpak ttf-jetbrains-mono-nerd keyd brightnessctl
```

Enable only persistent system services:

```bash
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now bluetooth.service
```

Do not enable a display manager. Do not manually start Xwayland or set `DISPLAY`; niri starts `xwayland-satellite` on demand.

## 5. Configure keyd safely

Before enabling keyd, keep another root-capable TTY open. Create `/etc/keyd/default.conf` with `sudoedit`:

```ini
[ids]
*

[main]
capslock = overload(hyper, esc)

[hyper:C-M-A-S]
```

This makes Caps Lock emit Escape on tap and Control+Meta+Alt+Shift while held. Then:

```bash
sudo systemctl enable --now keyd.service
sudo keyd reload
sudo journalctl -eu keyd --no-pager
```

Test both behaviors. The emergency keyd termination chord is Backspace+Escape+Enter.

## 6. Start the compositor checkpoint

Run from the TTY:

```bash
niri-session
```

On first start, niri creates its upstream default configuration if no user config exists. Use Super+T for Alacritty and Super+Shift+E to exit. Validate the generated configuration after returning to the TTY:

```bash
niri validate
journalctl --user -u niri -b --no-pager
```

The journal should show a Wayland socket and an X11 socket for on-demand satellite integration.

## 7. Validate portals and keyring

Start `niri-session` again, open Alacritty, and run:

```bash
systemctl --user status xdg-desktop-portal.service --no-pager
systemctl --user status xdg-desktop-portal-gnome.service --no-pager
busctl --user list | grep -E 'portal|secrets'
```

If the login keyring is not unlocked by the TTY PAM login, stop before editing PAM. Record `/etc/pam.d/login`, compare the distribution documentation, and add the standard optional `pam_gnome_keyring.so` auth/session integration only after making a root-readable backup. PAM changes are deliberately not automated by this guide.

## 8. Continue with the shared environment

Complete [the shared user and development setup](shared-user-environment.md). Zen and Nautilus can be launched from Alacritty in this shell-less profile.

## 9. Exit criteria

- explicit `niri-session` starts and exits cleanly;
- Super+T opens Alacritty;
- native Wayland applications and one test X11 client work;
- portal services start, and Zen can open a file chooser and request screen sharing;
- Wi-Fi, Bluetooth, PipeWire audio, and suspend/resume work;
- `brightnessctl get` reports the backlight and `brightnessctl set 5%-` then `brightnessctl set +5%` changes it; keybindings remain a later configuration task;
- there is no DMS, bar, launcher, notification daemon, greeter, or idle daemon.
