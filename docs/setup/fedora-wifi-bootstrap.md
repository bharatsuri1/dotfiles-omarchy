# Fedora 44 network and Wi-Fi bootstrap

This is the first gate for the Fedora Server + niri + DMS installation on the current laptop. Do not install the desktop until native Wi-Fi works after a fully updated Fedora boot.

## Why Ethernet comes first

The laptop uses Intel Wi-Fi PCI ID `8086:4d40` and working firmware named `iwlwifi-bz-b0-wh-b0-c102.ucode`. Fedora 44's release installer predates that exact firmware addition. Current Fedora 44 repositories do contain it, but the boot image may not.

Use the Fedora Everything network installer with tested Ethernet. Everything exposes Fedora's package environments without forcing a desktop, and its network source lets the target system receive current kernel and firmware packages during installation.

## 1. Download and authenticate Fedora Everything

As of August 2026, the current image is `Fedora-Everything-netinst-x86_64-44-1.7.iso`. Download the ISO and checksum from [Fedora's miscellaneous downloads](https://fedoraproject.org/everything/download/), then authenticate them in the download directory:

```bash
curl -O https://fedoraproject.org/fedora.gpg
gpgv --keyring ./fedora.gpg --output - \
  Fedora-Everything-44-1.7-x86_64-CHECKSUM \
  | sha256sum -c --ignore-missing
```

The ISO must report `OK`. Its Fedora-published SHA-256 is `bd285201494dd0ba09b54d05ac707de1401668b8512a573edb5922dcf9d7067e`. Use Fedora Media Writer or the carefully verified raw-device procedure; selecting the wrong device destroys its contents.

## 2. Prove Ethernet from the exact installer

Boot the USB and switch to a shell with Ctrl+Alt+F3. Confirm NetworkManager sees the Ethernet interface and prove the complete network path:

```bash
nmcli device status
ip -brief link
ip route
getent hosts fedoraproject.org
curl -I https://fedoraproject.org/
```

Do not begin an Everything installation unless routing, DNS, and HTTPS all work. Return to Anaconda with Ctrl+Alt+F1.

## 3. Record installer Wi-Fi support

Wi-Fi is not required during installation when Ethernet works, but record the release-image state before proceeding:

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

Native installer Wi-Fi passes only if all four work. If it fails while Ethernet works, continue over Ethernet; do not add random firmware files to the installer environment.

## 4. Select a custom minimal installation

In Anaconda:

- keep Ethernet connected and accept the official Fedora network source;
- choose the custom/minimal base environment;
- select no GNOME, KDE, Xfce, graphical administration, productivity, office, or multimedia add-on groups;
- follow the Btrfs, account, locale, and boot choices in [Fedora Server + niri + DMS](fedora-niri-dms.md);
- inspect the final software and storage summaries before starting installation.

Package count alone is not the acceptance test. The selected environment must be non-graphical and must not include a desktop group.

## 5. Update firmware and kernel on first boot

After booting the installed TTY, keep Ethernet connected. Verify HTTPS, then update the base before installing niri or DMS:

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

Disconnect Ethernet, then run:

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

- [Fedora Everything 44 download and verification](https://fedoraproject.org/everything/download/)
- [Fedora 44 `iwlwifi-mld-firmware`](https://packages.fedoraproject.org/pkgs/linux-firmware/iwlwifi-mld-firmware/fedora-44.html)
- [Upstream addition of the required Bz/Wh firmware](https://kernel.googlesource.com/pub/scm/linux/kernel/git/iwlwifi/linux-firmware/+/b21b48725314dcca554a8b23bc9c6004cece1042)
