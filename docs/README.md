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

1. **Installation/bootstrap** — Arch, Fedora Server, and Fedora Workstation installation paths.
2. **Disk and boot** — filesystem, bootloader, and swap for a minimal v1.
3. **Hardware foundation** — firmware, Intel microcode, graphics, Wi-Fi, and laptop input.
4. **Networking** — persistent Wi-Fi/Ethernet manager and DNS.
5. **Desktop session** — TTY launch, greeter, or display manager.
6. **niri and DMS** — required packages, startup ownership, and minimum configuration.
7. **Xwayland** — compatibility for non-Wayland development applications.
8. **Audio** — PipeWire and WirePlumber.
9. **Bluetooth** — BlueZ and DMS/GNOME control.
10. **Portals and authentication** — file chooser, screen sharing, polkit, and Secret Service.
11. **Laptop power** — suspend, lid behavior, brightness, and battery policy.
12. **Development foundation** — compilers, build tools, language/runtime management, and containers.
13. **Package-source policy** — native packages, Homebrew, Flatpak, and upstream binaries.
14. **Dotfile deployment** — installation and update mechanism for this repository.
15. **Updates and recovery** — safe upgrades, validation, logs, and rollback or reinstallation.

Optional productivity suites, media creation tools, printing, network-share extras, and other conveniences are deferred until the minimal development machine works.
