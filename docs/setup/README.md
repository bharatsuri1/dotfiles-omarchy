# First-install guides

These guides turn the v1 decisions into three installation paths for the current Dell Intel laptop.

1. [Arch + niri](arch-niri.md) is the compositor-learning checkpoint. It deliberately has no integrated desktop shell.
2. [Arch + niri + DMS](arch-niri-dms.md) is the first practical Arch desktop.
3. [Fedora Server + niri + DMS](fedora-niri-dms.md) is the first practical Fedora custom desktop.

All three use [the same hardware acceptance gate](hardware-preflight.md). The two Arch guides share the same ISO and `archinstall` base. All profiles finish with the [shared user/development environment](shared-user-environment.md).

These are reviewed command guides, not unattended installers. Read the whole selected guide before changing the disk. Commands that inspect state are intentional gates: stop when actual output does not match the stated expectation.

## Deliberate v1 omissions

- no disk encryption, hibernation, snapshots, custom bootloader, or unattended updates;
- no display manager for niri; log in on a TTY and run `niri-session`;
- no custom power stack or idle policy;
- no Docker daemon or global `docker` compatibility alias;
- no AUR workflow and therefore no VS Code on Arch;
- no visual redesign yet—the post-install design iteration will own appearance and interaction details.

## Source references

- [Arch installation guide](https://wiki.archlinux.org/title/Installation_guide)
- [archinstall documentation](https://archinstall.archlinux.page/)
- [niri getting started](https://github.com/niri-wm/niri/wiki/Getting-Started)
- [niri important software](https://github.com/niri-wm/niri/wiki/Important-Software)
- [DMS installation](https://danklinux.com/docs/dankmaterialshell/installation/)
- [DMS setup command](https://danklinux.com/docs/dankmaterialshell/cli-setup/)
