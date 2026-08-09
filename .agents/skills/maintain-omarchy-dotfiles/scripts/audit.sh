#!/usr/bin/env bash
set -u -o pipefail

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root" || exit 1
failures=0
warnings=0

pass() { printf 'PASS  %s\n' "$1"; }
fail() { printf 'FAIL  %s\n' "$1"; failures=$((failures + 1)); }
warn() { printf 'WARN  %s\n' "$1"; warnings=$((warnings + 1)); }

if [[ -z $(git status --porcelain=v1) ]]; then pass 'working tree clean'; else warn 'working tree has changes'; fi
git fsck --full >/dev/null 2>&1 && pass 'Git object integrity' || fail 'Git object integrity'
git diff --check >/dev/null && pass 'working-tree whitespace' || fail 'working-tree whitespace'

if command -v gitleaks >/dev/null; then
  gitleaks dir . --no-banner --redact --exit-code 1 >/dev/null 2>&1 && pass 'working-tree secret scan' || fail 'working-tree secret scan'
else
  warn 'gitleaks unavailable'
fi

bash -n .bashrc .bash_profile && pass 'Bash syntax' || fail 'Bash syntax'
zsh -n .zshenv .config/zsh/.zshrc && pass 'Zsh syntax' || fail 'Zsh syntax'
systemd-analyze verify .config/systemd/user/voxtype.service >/dev/null 2>&1 && pass 'Voxtype unit' || fail 'Voxtype unit'

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
pacman -Q | sort > "$tmp_dir/all"
pacman -Qqe | sort > "$tmp_dir/explicit"
pacman -Qqen | sort > "$tmp_dir/official"
pacman -Qqem | sort > "$tmp_dir/foreign"
cmp -s "$tmp_dir/all" packages-all-with-versions.txt && pass 'installed package snapshot' || fail 'installed package snapshot drift'
cmp -s "$tmp_dir/explicit" packages-explicit.txt && pass 'explicit package snapshot' || fail 'explicit package snapshot drift'
cmp -s "$tmp_dir/official" packages-official-explicit.txt && pass 'official package snapshot' || fail 'official package snapshot drift'
cmp -s "$tmp_dir/foreign" packages-foreign-explicit.txt && pass 'foreign package snapshot' || fail 'foreign package snapshot drift'

while IFS= read -r repo_file; do
  case "$repo_file" in
    .config/zen/*|.config/git/config) continue ;;
    .bash_profile|.bashrc|.zshenv|.config/*)
      live_file="$HOME/$repo_file"
      if [[ ! -f $live_file ]]; then
        fail "live mirror missing: $repo_file"
      elif ! cmp -s "$repo_file" "$live_file"; then
        fail "live mirror drift: $repo_file"
      fi
      ;;
  esac
done < <(git ls-files)
[[ $failures -eq 0 ]] && pass 'direct live mirrors'

if hyprctl version >/dev/null 2>&1; then
  if [[ -z $(hyprctl configerrors 2>/dev/null) ]]; then pass 'Hyprland config errors'; else fail 'Hyprland config errors'; fi
else
  warn 'Hyprland runtime unavailable'
fi

printf '\nSummary: failures=%s warnings=%s\n' "$failures" "$warnings"
[[ $failures -eq 0 ]]
