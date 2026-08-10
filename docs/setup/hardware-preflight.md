# Hardware and installation-media preflight

Run this gate from the exact ISO that will perform the installation. Do not erase the disk merely because the ISO boots.

## Known hardware

The current laptop has:

- Intel Wi-Fi 7 BE213 160 MHz: PCI `8086:4d40`, subsystem `8086:4314`, driver `iwlwifi`;
- Intel Bluetooth: PCI `8086:4d76`;
- Intel Wildcat Lake graphics: PCI `8086:fd80`, kernel driver `xe`;
- Intel SOF audio and a Kioxia NVMe drive.

The current working reference is Arch kernel `7.1.4-arch1-1` with `linux-firmware-intel` `20260622-1`. It loads Wi-Fi firmware `iwlwifi-bz-b0-wh-b0-c102.ucode` API 102. This is evidence that the combination works; it is not a claimed minimum.

## Before booting the ISO

1. Download the latest official ISO from Arch or Fedora.
2. Verify its checksum and signature using that distribution's official instructions.
3. Put only the verified image on the installer USB.
4. Prepare and test USB phone tethering or wired Ethernet as the fallback.
5. Complete a Restic backup and restore one representative file before touching partitions.

## In the live ISO

Record the live kernel and devices:

```bash
uname -r
lspci -nnk
```

The network block must show `8086:4d40` and `Kernel driver in use: iwlwifi`. Then inspect firmware loading:

```bash
journalctl -b -k --no-pager | grep -Ei 'iwlwifi|firmware'
```

Accept only an actual firmware-load success. On the known-working system the identifying lines include BE213, PCI `4d40/4314`, and `bz-b0-wh-b0-c102.ucode`.

For the Arch ISO, connect with iwd only for installation:

```bash
iwctl
```

Inside the prompt, replace `wlan0` when `device list` reports another interface:

```text
device list
station wlan0 scan
station wlan0 get-networks
station wlan0 connect YOUR_SSID
exit
```

Fedora's installer uses NetworkManager. If a shell is available, inspect it with:

```bash
nmcli device status
nmcli device wifi list
```

Prove the complete network path, not just association:

```bash
ip address
ip route
getent hosts archlinux.org
curl -I https://archlinux.org/
```

For a Fedora ISO, substitute `https://fedoraproject.org/` in the last command.

## Stop conditions

Do not start installation if any of these is true:

- `iwlwifi` does not bind to `8086:4d40`;
- firmware loading fails or loops;
- the adapter cannot scan and authenticate;
- DHCP, DNS, or HTTPS access fails;
- neither Wi-Fi nor the tested tether/wired fallback works.

An ISO failing this gate is rejected. Download a newer official image or use the tested fallback; do not try to repair the target system after erasing it.

## First-boot hardware validation

After installation, capture the new reference:

```bash
uname -r
lspci -nnk
journalctl -b -k --no-pager | grep -Ei 'iwlwifi|firmware|xe |sof-audio|bluetooth'
findmnt -no FSTYPE /
swapon --show
```

Expected results are `btrfs` for `/`, zram-only swap, `iwlwifi` for Wi-Fi, and `xe` for graphics.

Install the profile's selected Intel media packages, then verify enumeration:

```bash
vainfo
```

Finally test hardware decoding in Zen or mpv while observing GPU activity. `vainfo` success alone does not prove the selected application is using hardware decode.

## Research references

- [linux-firmware Intel iwlwifi files](https://gitlab.com/kernel-firmware/linux-firmware/-/tree/main/intel/iwlwifi)
- [Intel oneVPL GPU runtime](https://github.com/intel/vpl-gpu-rt)
- [Fedora oneVPL runtime package](https://packages.fedoraproject.org/pkgs/intel-vpl-gpu-rt/intel-vpl-gpu-rt/)
- [Fedora libvpl implementation guidance](https://packages.fedoraproject.org/pkgs/libvpl/libvpl/)

