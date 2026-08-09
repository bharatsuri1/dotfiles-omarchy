# Inclusion policy

## Include

Include a file when all are true:

1. It changes user-visible behavior or declares required tooling.
2. The user authored or intentionally selected it.
3. A fresh machine can consume it without machine-specific state.
4. It contains no credentials or private session material.
5. Omarchy or an application will not deterministically regenerate the same file.

Typical examples: shell startup, Hypr overrides, application preferences, runtime declarations, authored user services, curated browser CSS, package manifests.

## Exclude

- Secrets: API keys, private keys, password stores, cookies, login databases, GitHub hosts/auth files, Pulse cookies.
- Runtime state: logs, sessions, histories unless explicitly intended, sockets, locks, PID files, WAL/SHM files.
- Databases and caches: browser profiles, telemetry, indexes, compiled caches, Fcitx cached layouts.
- Generated ownership: theme-current trees, Herdr managed plugins, application-generated integrations.
- Installed payloads: Homebrew Cellar, Mise runtimes, package caches, binaries, cloned plugin working trees.
- Stock Omarchy copies with no intentional override.

## Review tests

### Provenance

Compare a candidate against the same basename and likely path under Omarchy `config/` and `default/`. An exact match is evidence that installation recreates it. A difference is evidence, not proof, of customization; inspect the diff.

### Portability

Flag absolute home paths, hostnames, monitor connector names, device IDs, profile hashes, and architecture-specific paths. Keep them only when the repository intentionally targets this machine and the restore docs say so.

### Privacy

Scan content and filenames. Package names containing words such as `secret` or `1password` are not findings by themselves. Inspect matches in context. Use Gitleaks over the working tree so untracked additions are scanned.

### Nested repositories

Record upstream URL and exact revision in restore instructions. Add the directory to `.gitignore`. Vendor only when offline restoration is an explicit requirement.

### Drift direction

Never assume the newest timestamp is authoritative. Show content differences and decide whether live configuration should update the repo or the repo should repair live state.
