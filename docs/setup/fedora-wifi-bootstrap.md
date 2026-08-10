# Fedora 44 Wi-Fi bootstrap

This is the first gate for the Fedora Server + niri + DMS installation on the current laptop. Do not install the desktop until native Wi-Fi works after a fully updated Fedora boot.

## Why the fallback path is mandatory

The laptop uses Intel Wi-Fi PCI ID `8086:4d40` and working firmware named `iwlwifi-bz-b0-wh-b0-c102.ucode`. Fedora Server 44's release DVD predates that exact firmware addition. Current Fedora 44 updates do contain it, but the installer image may not.

Use the full Fedora Server DVD ISO, not the network-install ISO. The DVD can install the base without Internet access. Have USB phone tethering or a tested wired USB adapter available for the first update.

## 1. Download and authenticate the DVD

As of August 2026, the current release image is `Fedora-Server-dvd-x86_64-44-1.7.iso`. Download the ISO and its checksum from the [official Fedora Server page](https://fedoraproject.org/en/server/download/), then authenticate them in the download directory:

```bash
curl -O https://fedoraproject.org/fedora.gpg
gpgv --keyring ./fedora.gpg --output - \
  Fedora-Server-44-1.7-x86_64-CHECKSUM \
  | sha256sum -c --ignore-missing
```

The ISO must report `OK`. Its Fedora-published SHA-256 is `85837793bfa36db6bc709b4cecd2ec116951b87d9c53c3d95eb2fac8dcf7cf1f`. Use Fedora Media Writer to write it to USB; selecting the wrong raw block device with `dd` can destroy another disk.

## 2. Test Wi-Fi from the exact installer

Boot the USB and switch to a shell with Ctrl+Alt+F3 if the installer does not expose one. Record the kernel, adapter, driver, and firmware:

```bash
uname -r
lspci -nnk -d 8086:4d40
find /usr/lib/firmware -type f -name '*bz-b0-wh-b0-c102*' -print
journalctl -b -k --no-pager | grep -Ei 'iwlwifi|firmware'
nmcli device status
rfkill list
```

If Wi-Fi is soft-blocked:

```bash
sudo rfkill unblock wifi
nmcli radio wifi on
```

If `nmcli` shows a Wi-Fi interface, try the native connection without placing its password in shell history:

```bash
nmcli device wifi rescan
nmcli --fields IN-USE,SSID,SIGNAL,SECURITY device wifi list
sudo nmcli device wifi connect 'YOUR_SSID' --ask
```

Prove association, routing, DNS, and HTTPS:

```bash
nmcli device status
ip route
getent hosts fedoraproject.org
curl -I https://fedoraproject.org/
```

Native installer Wi-Fi passes only if all four work. If `8086:4d40` has no `Kernel driver in use`, the firmware file is absent, or the journal reports a firmware-load failure, stop troubleshooting the installer image and use the fallback path.

## 3. Prove the fallback before installation

Enable USB tethering on the phone, attach it directly, and inspect the new interface:

```bash
nmcli device status
ip -brief link
```

NetworkManager normally connects it automatically. If the new Ethernet-like interface is disconnected, replace the example name with the one shown by `nmcli`:

```bash
sudo nmcli device connect enp0s20f0u1
```

Repeat the route, DNS, and HTTPS tests. Do not erase the disk until either native Wi-Fi or this fallback has passed.

## 4. Install the offline-capable base

Return to the installer with Ctrl+Alt+F1. Continue with the storage and account choices in [Fedora Server + niri + DMS](fedora-niri-dms.md). It is safe to install from the DVD while Wi-Fi is unavailable; do not enable an online package source during this first pass.

## 5. Update firmware and kernel on first boot

After booting the installed TTY, connect the proven tether or wired fallback. Verify HTTPS, then update the base before installing niri or DMS:

```bash
curl -I https://fedoraproject.org/
sudo dnf upgrade --refresh
sudo dnf install \
  kernel kernel-core kernel-modules kernel-modules-core \
  linux-firmware iwlwifi-mld-firmware \
  NetworkManager NetworkManager-wifi
rpm -q kernel linux-firmware iwlwifi-mld-firmware NetworkManager-wifi
sudo systemctl enable NetworkManager.service
sudo reboot
```

Do not test only by reloading `iwlwifi`: boot the newly installed kernel and firmware together.

## 6. Accept native Wi-Fi after reboot

Disconnect the tether, then run:

```bash
uname -r
lspci -nnk -d 8086:4d40
find /usr/lib/firmware -type f -name '*bz-b0-wh-b0-c102*' -print
sudo journalctl -b -k --no-pager | grep -Ei 'iwlwifi|firmware'
nmcli radio wifi on
nmcli device wifi rescan
nmcli --fields IN-USE,SSID,SIGNAL,SECURITY device wifi list
sudo nmcli device wifi connect 'YOUR_SSID' --ask
```

Then prove the complete path again:

```bash
nmcli device status
ip route
getent hosts fedoraproject.org
curl -I https://fedoraproject.org/
```

Only now continue to the niri and DMS packages. Leave NetworkManager's default Wi-Fi power policy unchanged in v1.

## Failure record

If updated Fedora still cannot connect, do not add random firmware files or kernel parameters. Save these diagnostics to removable storage and investigate the exact failure first:

```bash
uname -a
rpm -q kernel linux-firmware iwlwifi-mld-firmware NetworkManager-wifi
lspci -nnk -d 8086:4d40
sudo journalctl -b -k --no-pager | grep -Ei 'iwlwifi|firmware'
nmcli general status
nmcli device status
rfkill list
```

## References

- [Fedora Server 44 download and verification](https://fedoraproject.org/en/server/download/)
- [Fedora 44 `iwlwifi-mld-firmware`](https://packages.fedoraproject.org/pkgs/linux-firmware/iwlwifi-mld-firmware/fedora-44.html)
- [Upstream addition of the required Bz/Wh firmware](https://kernel.googlesource.com/pub/scm/linux/kernel/git/iwlwifi/linux-firmware/+/b21b48725314dcca554a8b23bc9c6004cece1042)
