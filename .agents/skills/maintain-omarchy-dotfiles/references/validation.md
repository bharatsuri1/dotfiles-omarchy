# Validation matrix

Run the repository baseline first:

```bash
.agents/skills/maintain-omarchy-dotfiles/scripts/audit.sh
```

Then apply every relevant component check below.

| Surface | Check | Passing criterion |
|---|---|---|
| Git | `git status --short`; `git fsck --full` | Expected changes only; no integrity output. |
| Remote | `git rev-list --left-right --count origin/main...HEAD` | `0 0` after a requested push. |
| Whitespace | `git diff --check` and `git diff --cached --check` | No errors. Preserve harmless source formatting only deliberately. |
| Secrets | `pre-commit run --all-files`; `gitleaks dir . --no-banner --redact` | Both pass; scan includes untracked files. |
| Bash | `bash -n .bashrc .bash_profile` | Exit 0. |
| Zsh | `zsh -n .zshenv .config/zsh/.zshrc` | Exit 0. Test a clean login environment for PATH initialization changes. |
| Tmux | Start a detached session with an isolated socket and repository config | Session starts and queried options match intent; kill the test server. |
| Hyprland | `hyprctl reload`; `hyprctl configerrors` | Reload says `ok`; configerrors is empty. |
| systemd unit | `systemd-analyze verify <unit>` | Exit 0 and no diagnostics. |
| Pacman | Compare current queries to manifest files | Exact contents/counts match after refresh. |
| Brew | `brew bundle check --file ./Brewfile --no-upgrade` | Dependencies satisfied. Use the absolute brew path if PATH is the subject under test. |
| Live mirror | `cmp -s <repo> "$HOME/<repo>"` | Exit 0 for direct mirrors. Exclude curated Zen files and intentional Git identity divergence. |
| Zen | Resolve active profile from `profiles.ini`, compare curated files individually | Every intended active file matches; missing `user.js` is reported as inactive, not silently accepted. |

## Runtime limitations

Socket failures in headless or sandboxed sessions leave runtime validation unverified. Report the command and error. Do not convert an unavailable runtime check into a pass.

## Completion report

State:

- clean checks;
- drift found and its direction;
- excluded state or secrets;
- runtime checks that could not execute;
- commit and remote synchronization state.
