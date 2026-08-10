# Linux setup directions

This documentation will grow into reproducible setup guides for one Dell Intel laptop. The directions are deliberately incremental so they can be used both to learn the Linux desktop stack and to reach a practical daily system.

## Directions

- **Arch base** — minimal bootable TTY system.
- **Arch + niri** — hand-assembled Wayland desktop.
- **Arch + niri + DMS** — integrated Quickshell-based Arch desktop.
- **Fedora Server + niri** — hand-assembled niri desktop on Fedora.
- **Fedora Server + niri + DMS** — integrated Quickshell-based Fedora desktop.
- **Fedora Workstation + GNOME** — complete, ready-to-use GNOME desktop.

The first practical custom-system target is Arch + niri + DMS. DMS is a v1 compromise that supplies a complete shell quickly and can be decomposed in a later iteration. Fedora Workstation + GNOME is the simple, batteries-included alternative.

## Documentation model

Each guide will compose four layers instead of duplicating a monolithic install:

1. distribution bootstrap;
2. graphical session;
3. shared development defaults;
4. profile-specific validation and recovery.

No setup commands should imply an undecided component. Decisions are tracked in [decisions.md](decisions.md).

## Remaining critical decisions

Only components required to boot, connect, enter a graphical session, develop, update, and recover remain in scope:

1. **Installation/bootstrap** — selected: official ISO paths for Arch, Fedora Server, and Fedora Workstation; exact installer validation steps remain to be written.
2. **Disk and boot** — selected: Btrfs, automatic whole-disk unencrypted partitioning, profile-specific bootloaders, and zram-only swap without hibernation.
3. **Hardware foundation** — standard kernels, Intel microcode, firmware, Intel graphics, libinput, and keyd selected; installer Wi-Fi compatibility and Wildcat Lake media acceleration are mandatory investigations.
4. **Networking** — selected: NetworkManager as the single persistent network owner; ISO driver/firmware preflight remains.
5. **Desktop session** — selected: explicit `niri-session` from TTY for custom directions and GDM/GNOME for Workstation; no custom greeter or shell autostart.
6. **niri and DMS** — selected and detailed: packaged DMS core only, accepting required dependencies while excluding visualizer, generated themes, indexed search, calendar, sound feedback, plugins, and other optional providers.
7. **Xwayland** — selected: niri-managed on-demand `xwayland-satellite`, with native Wayland preferred and no Xorg session.
8. **Audio** — selected: PipeWire, WirePlumber, PulseAudio compatibility, and ALSA integration; DMS/GNOME owns the UI.
9. **Bluetooth** — selected: BlueZ backend, its CLI tools, DMS/GNOME UI, and PipeWire audio; no Blueman or OBEX.
10. **Portals and authentication** — selected: niri portal set, GNOME Keyring/libsecret, and polkit with one profile-owned agent; TTY keyring-unlock integration requires validation.
11. **Laptop power** — selected: retain distribution/systemd defaults, validate the basic hardware behavior, and defer custom policy, timers, and optimization.
12. **Development foundation** — selected: native build toolchains, Mise for non-Python runtimes, uv for Python, rootless Podman, and explicit `podman compose` compatibility.
13. **Package-source policy** — selected and mapped for v1: distribution repositories first, named project repositories and Flatpak/Homebrew only for recorded packages, Herdr as the direct-upstream exception, and no Arch AUR workflow.
14. **Dotfile deployment** — selected: GNU Stow from a dedicated package subtree with collision preflight and no secrets/runtime state.
15. **Updates and recovery** — manual multi-source updates plus TTY/ISO/chroot/reinstall recovery selected; Restic is the user-data backup mechanism with a prompted destination and manual v1 workflow.

Optional productivity suites, media creation tools, printing, network-share extras, and other conveniences are deferred until the minimal development machine works.
