# Build an updated Fedora 44 installer with Lorax

This procedure rebuilds Fedora's Anaconda boot environment from the Fedora 44 release and updates repositories. It is a learning artifact and a hardware-specific installer, not an official Fedora image.

The stock Everything 44 compose 1.7 ISO contains kernel `6.19.10-300.fc44.x86_64`. The current laptop works on a newer kernel and needs Intel firmware `iwlwifi-bz-b0-wh-b0-c102.ucode`. Supplying both repositories lets DNF select newer kernel, driver, and firmware packages as one coherent installer runtime.

## What Lorax builds

Lorax:

1. resolves an Anaconda runtime from the supplied RPM repositories;
2. installs it into a temporary root;
3. uses its runtime templates to remove unnecessary installation-environment files;
4. creates the SquashFS `images/install.img`;
5. creates a matching initramfs;
6. copies the selected kernel;
7. constructs a bootable hybrid `images/boot.iso`.

This is different from repacking the published ISO. The kernel, modules, firmware, userspace, and installer runtime are resolved together from Fedora packages.

## Why a Fedora 44 container

Lorax templates are release-sensitive, so Fedora recommends running Lorax from the same release being built. The current host is Arch and already has Docker installed. A privileged Fedora 44 container supplies Fedora's Lorax packages without installing its compose stack on Arch.

The container is privileged because Lorax needs loop devices and filesystem mounts while constructing `install.img`. The repository build directory is its only writable host bind mount.

The build script also checks `/dev/loop-control` and the host's loop block-device nodes before Docker starts. On this Arch host the kernel `loop` module was loaded, but `/dev/loop0` was missing; Docker therefore could not expose it even to a privileged container.

## Review the build script

Read [the complete build script](../../scripts/build-fedora-lorax-iso) before running it:

```bash
less scripts/build-fedora-lorax-iso
```

Its important Lorax invocation is:

```bash
lorax \
  --product Fedora \
  --version 44 \
  --release 44 \
  --variant Everything \
  --buildarch x86_64 \
  --volid FEDORA-44-LATEST \
  --isfinal \
  --nomacboot \
  --source https://download.fedoraproject.org/pub/fedora/linux/releases/44/Everything/x86_64/os/ \
  --source https://download.fedoraproject.org/pub/fedora/linux/updates/44/Everything/x86_64/ \
  /work/results
```

The second `--source` is essential: when the same package exists in both repositories, DNF selects the newer update.

## Confirm what “latest” means

Do not infer the selected kernel solely from Fedora's website or from the host system. Immediately before Lorax runs, the build container queries its enabled Fedora 44 release and stable-updates repositories:

```bash
dnf repoquery \
  --available \
  --arch x86_64 \
  --latest-limit 1 \
  --queryformat '%{name}-%{evr}.%{arch}' \
  kernel kernel-core kernel-modules kernel-modules-core

dnf repoquery \
  --available \
  --arch noarch \
  --latest-limit 1 \
  --queryformat '%{name}-%{evr}.%{arch}' \
  iwlwifi-mld-firmware
```

The script records that output, the UTC build time, enabled repositories, and Lorax version in:

```text
build/fedora-44-lorax/build-inputs.txt
```

During the August 9, 2026 test session, the live stable repositories returned `7.1.7-200.fc44`, newer than the earlier `7.1.5` package-index snapshot. This demonstrates why repository state must be queried rather than copied into a permanent assumption. This build does not enable updates-testing; `build-inputs.txt` is the evidence for the actual compose.

## Manual Docker input inspection

The build script automates the final process. To learn and verify its inputs interactively, create the host build directory and enter a Fedora 44 container:

```bash
mkdir -p build/fedora-44-lorax

sudo docker run --rm -it \
  --privileged \
  --security-opt label=disable \
  --volume "$PWD/build/fedora-44-lorax:/work:rw" \
  --workdir /work \
  docker.io/library/fedora:44 \
  bash
```

Inside the container:

```bash
dnf install -y lorax dnf5-plugins file
mkdir -p /work/kernel-check
```

Query and download architecture-specific kernel packages:

```bash
dnf repoquery \
  --available \
  --arch x86_64 \
  --latest-limit 1 \
  --queryformat '%{name}-%{evr}.%{arch}' \
  kernel kernel-core kernel-modules kernel-modules-core

dnf download \
  --destdir /work/kernel-check \
  --arch x86_64 \
  kernel-core kernel-modules-core
```

Firmware RPMs are `noarch`; using only `--arch x86_64` incorrectly reports that `iwlwifi-mld-firmware` is unavailable:

```bash
dnf repoquery \
  --available \
  --arch noarch \
  --latest-limit 1 \
  --queryformat '%{name}-%{evr}.%{arch}' \
  iwlwifi-mld-firmware

dnf download \
  --destdir /work/kernel-check \
  --arch noarch \
  iwlwifi-mld-firmware
```

Inspect the exact RPM identities and verify their Fedora signatures:

```bash
rpm -qp \
  --queryformat '%{name}-%{evr}.%{arch}\n' \
  /work/kernel-check/*.rpm

rpm -K /work/kernel-check/*.rpm
```

Confirm the selected firmware RPM contains this laptop's exact Bz/Wh payload:

```bash
rpm -qlp /work/kernel-check/iwlwifi-mld-firmware-*.rpm \
  | grep 'iwlwifi-bz-b0-wh-b0-c102'
```

The test session resolved:

```text
kernel-core-7.1.7-200.fc44.x86_64
kernel-modules-core-7.1.7-200.fc44.x86_64
iwlwifi-mld-firmware-20260622-1.fc44.noarch
```

The firmware RPM contained both the canonical Fedora path and compatibility path:

```text
/usr/lib/firmware/intel/iwlwifi/iwlwifi-bz-b0-wh-b0-c102.ucode.xz
/usr/lib/firmware/iwlwifi-bz-b0-wh-b0-c102.ucode.xz
```

These manual downloads prove repository availability and payload content. Lorax still resolves its own complete runtime from the explicit release and updates sources below; the downloaded RPM directory is diagnostic evidence, not an override repository.

## Recover from a missing loop-device node

The first manual compose successfully built the updated runtime, kernel, initramfs, and `install.img`, then failed in `mkefiboot` with:

```text
losetup: device node /dev/loop0 (7:0) is lost
```

That means Lorax reached the final boot-image phase but the container lacked the device node required to construct its FAT EFI image. It is not a package-resolution or Fedora-runtime failure.

If the original privileged container is still open, create the standard loop nodes inside it and verify allocation:

```bash
test -r /sys/class/misc/loop-control/dev
mknod -m 0660 /dev/loop-control c 10 237

for number in $(seq 0 7); do
  test -e "/dev/loop${number}" \
    || mknod -m 0660 "/dev/loop${number}" b 7 "${number}"
done

losetup -f
```

Expected:

```text
/dev/loop0
```

Preserve the incomplete output for diagnosis before retrying, because Lorax requires a new output directory:

```bash
mv /work/results /work/results.failed-no-loop
```

Then rerun the same Lorax command. A fresh run through `scripts/build-fedora-lorax-iso` performs the host-side node check automatically before starting Docker.

The incomplete test output proved that Lorax selected kernel `7.1.7-200.fc44.x86_64` and firmware `iwlwifi-mld-firmware-20260622-1.fc44.noarch`. It must not be flashed because UEFI image and final `boot.iso` construction did not finish.

## Build

The current user cannot access `/var/run/docker.sock`, so invoke the script through `sudo`. The script records the original user's UID and restores artifact ownership afterward:

```bash
sudo ./scripts/build-fedora-lorax-iso
```

The first build downloads the Fedora 44 container, Lorax, Anaconda dependencies, current kernel, and firmware. Expect several gigabytes of downloads and temporary files.

The output is:

```text
build/fedora-44-lorax/results/images/boot.iso
build/fedora-44-lorax/results/images/boot.iso.sha256
build/fedora-44-lorax/build-inputs.txt
build/fedora-44-lorax/firmware-check.txt
```

Generated artifacts are ignored by Git. If results already exist, the script preserves them in a UTC timestamped directory rather than deleting them.

## Inspect the result

```bash
./scripts/verify-fedora-lorax-iso \
  build/fedora-44-lorax/results/images/boot.iso
```

This verifies that expected ISO artifacts exist, prints the embedded kernel version, reads adjacent tree metadata, and lists the required firmware from the final SquashFS when `unsquashfs` is available. It does not claim Wi-Fi compatibility from package presence alone.

The first successful compose produced a bootable 1,213,947,904-byte ISO with volume ID `FEDORA-44-LATEST`, embedded kernel `7.1.7-200.fc44.x86_64`, a matching initramfs, a 894,976,000-byte SquashFS installer runtime, BIOS El Torito image, and UEFI boot image. Lorax implanted the checksum used by the boot menu's media-test entry. Direct SquashFS inspection confirmed the 633,396-byte `iwlwifi-bz-b0-wh-b0-c102.ucode.xz` payload and its compatibility symlink survived runtime cleanup.

## Boot acceptance test

Flash the new ISO only after reviewing its checksum and confirming its kernel is newer than the stock `6.19.10` build. Boot it and run:

```bash
uname -r
lspci -nnk -d 8086:4d40
find /usr/lib/firmware -type f -name '*bz-b0-wh-b0-c102*' -print
journalctl -b -k --no-pager | grep -Ei 'iwlwifi|firmware'
nmcli device status
```

Acceptance requires:

- PCI `8086:4d40` is bound to `iwlwifi`;
- the Bz/Wh `c102` firmware exists and loads without a terminal error;
- NetworkManager exposes a Wi-Fi interface;
- scanning, authentication, DHCP, DNS, and HTTPS work.

Ethernet remains available for the Everything package source. The Lorax `boot.iso` supplies the installer runtime; Anaconda may still require selecting or entering the official Fedora Everything network repository as its installation source.

## Trust boundary

The result is locally generated and is not signed by Fedora as an official release ISO. Its RPM inputs remain Fedora-signed and DNF-verified. Record the build date, repository URLs, Lorax version, selected kernel, firmware package version, and output SHA-256 before using or sharing it.

## References

- [Lorax command and build process](https://weldr.io/lorax/lorax.html)
- [Fedora Everything downloads](https://fedoraproject.org/everything/download/)
- [Fedora kernel package versions](https://packages.fedoraproject.org/pkgs/kernel/kernel/)
- [Fedora `iwlwifi-mld-firmware`](https://packages.fedoraproject.org/pkgs/linux-firmware/iwlwifi-mld-firmware/)
