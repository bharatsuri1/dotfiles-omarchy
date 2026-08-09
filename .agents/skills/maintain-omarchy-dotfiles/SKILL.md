---
name: maintain-omarchy-dotfiles
description: Maintain this Omarchy dotfiles repository. Use for auditing home-directory drift, selecting and syncing portable configs, changing Hyprland or shell setup, refreshing Pacman or Homebrew manifests, reviewing restore coverage, validating components, committing dotfile updates, or preparing a clean push.
---

# Maintain Omarchy Dotfiles

Keep the repository reproducible, portable, and free of runtime state. Treat `$HOME` as the live source, this repository as the restore source, and `~/.local/share/omarchy/` as read-only upstream reference.

## Maintenance loop

### 1. Establish the baseline

Run `git status --short`, identify the branch and remote, and read `README.md` plus `.gitignore`. Inventory recent live changes before editing. Preserve unrelated work.

Completion: every pre-existing repository change and every live component in scope is identified.

### 2. Classify each candidate

Read [references/inclusion-policy.md](references/inclusion-policy.md). For component ownership, source location, and portability, read [references/components.md](references/components.md).

Classify each candidate as:

- `portable`: authored configuration worth restoring;
- `upstream`: stock Omarchy material recreated by installation;
- `generated`: caches, logs, databases, locks, sessions, compiled data, or managed integrations;
- `sensitive`: credentials, tokens, cookies, keys, authentication state, private host data;
- `uncertain`: inspect provenance and ask before capture when the choice changes behavior or privacy.

Completion: every candidate has one classification and every proposed repository addition is `portable`.

### 3. Compare before syncing

Use `cmp`, `diff -u`, checksums, timestamps, and upstream comparisons. An exact match to `~/.local/share/omarchy/config/` or `~/.local/share/omarchy/default/` is normally `upstream`. Prefer explicit file paths over directory-wide synchronization.

For live edits, update the live file and repository mirror together. For capture tasks, copy from live to the matching repository path. Keep the `$HOME`-relative layout.

Completion: the intended source wins deliberately, copied files match byte-for-byte, and no unrelated file moved.

### 4. Refresh manifests when system state changed

Run `scripts/refresh-package-manifests.sh` after Pacman changes. Add `--brew` after Homebrew formula or tap changes. Keep restoration lists separate from the full version snapshot.

Completion: explicit packages equal official plus foreign packages, and manifest counts match the current system.

### 5. Update restore instructions

Read [references/restore.md](references/restore.md) when adding a component, service, plugin, runtime manager, or non-Pacman dependency. Update `README.md` only when the restore path changes. Include activation steps that copying cannot reproduce, such as `systemctl --user enable`, `mise install`, plugin installation, or `chsh`.

Completion: a clean Omarchy installation can reconstruct the changed behavior from tracked files and documented commands.

### 6. Validate the affected surface

Read [references/validation.md](references/validation.md), then run the checks for every affected component. Run `scripts/audit.sh` for the repository-wide baseline. Treat unavailable runtime sockets as explicit limitations, not successful checks.

Completion: every applicable check passes, or the final report names the exact unverified check and reason.

### 7. Commit and push deliberately

Review the complete diff and untracked files. Run `git diff --check`, the configured pre-commit hooks, and a working-tree secret scan before committing. Separate config changes from generated package snapshots when both are substantial. Use outcome-based commit messages. Push only when the user requests it.

Completion: commits contain only reviewed files; after a requested push, the worktree is clean and `git rev-list --left-right --count origin/main...HEAD` reports `0 0`.

## Guardrails

- Keep `~/.local/share/omarchy/` read-only. Use it only to establish upstream provenance.
- Resolve the exact targets before any overwrite, removal, broad copy, or package-manifest rewrite.
- Keep credentials and application state outside Git even when technically portable.
- Preserve nested upstream repositories as pinned installation instructions instead of vendoring them by default.
- Validate current Hyprland window-rule syntax against the official documentation before changing window rules.
- After changing live Hyprland configuration, run `hyprctl reload` and `hyprctl configerrors` until clean.
