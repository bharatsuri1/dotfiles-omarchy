# Restore sequence

Use this reference when tracked coverage or installation requirements change. Keep the user-facing commands in `README.md` authoritative.

## Order

1. Install or update Omarchy so stock sources exist.
2. Install official Pacman packages from `packages-official-explicit.txt`.
3. Install foreign packages from `packages-foreign-explicit.txt` with the available AUR helper.
4. Install Homebrew and apply `Brewfile`.
5. Copy direct mirrors to their `$HOME`-relative locations.
6. Install pinned third-party shell plugins without vendoring them.
7. Run runtime managers such as `mise install`.
8. Enable authored user services and reload systemd.
9. Place curated Zen files into the active profile.
10. Select the login shell and restart the session where required.
11. Run the validation matrix against the restored machine.

## Restore-only state

File copies do not encode:

- login-shell selection (`chsh`);
- enabled systemd units;
- checked-out revisions of excluded plugin repositories;
- application extension installation;
- active browser profile selection;
- current Omarchy theme/background;
- secrets and authenticated sessions.

Document these as commands or explicit manual steps. Keep secrets in their native secure setup flow.

## Manifest intent

- `packages-official-explicit.txt`: primary official-package restore input.
- `packages-foreign-explicit.txt`: primary AUR/foreign restore input.
- `packages-explicit.txt`: combined reconciliation list.
- `packages-all-with-versions.txt`: diagnostic snapshot, not the preferred restore input.
- `packages-orphans-with-versions.txt`: cleanup review; never uninstall automatically from this list.
- `Brewfile`: Homebrew tap/formula restore input.
