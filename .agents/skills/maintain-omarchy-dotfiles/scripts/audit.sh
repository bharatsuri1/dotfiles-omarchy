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
  gitleaks dir . --no-banner --redact --exit-code 1 --max-target-megabytes 10 --timeout 60 >/dev/null 2>&1 && pass 'working-tree secret scan' || fail 'working-tree secret scan'
else
  warn 'gitleaks unavailable'
fi

bash -n .bashrc .bash_profile && pass 'Bash syntax' || fail 'Bash syntax'
zsh -n .zshenv .config/zsh/.zshenv .config/zsh/.zshrc && pass 'Zsh syntax' || fail 'Zsh syntax'
unit_output=$(systemd-analyze verify .config/systemd/user/voxtype.service 2>&1)
unit_status=$?
if [[ $unit_status -eq 0 ]]; then
  pass 'Voxtype unit'
elif [[ $unit_output == *'Operation not permitted'* ]]; then
  warn 'Voxtype unit verification unavailable in sandbox'
else
  fail 'Voxtype unit'
  printf '%s\n' "$unit_output" >&2
fi

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
pacman -Q | LC_ALL=C sort > "$tmp_dir/all"
pacman -Qqe | LC_ALL=C sort > "$tmp_dir/explicit"
pacman -Qqen | LC_ALL=C sort > "$tmp_dir/official"
pacman -Qqem | LC_ALL=C sort > "$tmp_dir/foreign"
pacman -Qdt | LC_ALL=C sort > "$tmp_dir/orphans"
cmp -s "$tmp_dir/all" packages-all-with-versions.txt && pass 'installed package snapshot' || fail 'installed package snapshot drift'
cmp -s "$tmp_dir/explicit" packages-explicit.txt && pass 'explicit package snapshot' || fail 'explicit package snapshot drift'
cmp -s "$tmp_dir/official" packages-official-explicit.txt && pass 'official package snapshot' || fail 'official package snapshot drift'
cmp -s "$tmp_dir/foreign" packages-foreign-explicit.txt && pass 'foreign package snapshot' || fail 'foreign package snapshot drift'
cmp -s "$tmp_dir/orphans" packages-orphans-with-versions.txt && pass 'orphan package snapshot' || fail 'orphan package snapshot drift'

while IFS= read -r repo_file; do
  case "$repo_file" in
    .config/zen/*|.config/git/config) continue ;;
    .bash_profile|.bashrc|.zshenv|.XCompose|.config/*)
      live_file="$HOME/$repo_file"
      if [[ ! -f $live_file ]]; then
        fail "live mirror missing: $repo_file"
      elif [[ $repo_file == .config/user-dirs.dirs ]] && diff -q \
        <(sed 's/[[:space:]]*$//' "$repo_file") \
        <(sed 's/[[:space:]]*$//' "$live_file") >/dev/null; then
        : # xdg-user-dirs generated comment whitespace is non-semantic.
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

if command -v brew >/dev/null; then
  HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file ./Brewfile --no-upgrade >/dev/null 2>&1 && pass 'Homebrew bundle' || fail 'Homebrew bundle drift'
else
  warn 'Homebrew runtime unavailable'
fi

if [[ -f snapshots/current-omarchy-state.env ]]; then
  # This repository-owned file contains only fixed version/checksum strings.
  source snapshots/current-omarchy-state.env

  [[ $(cat "$HOME/.local/share/omarchy/version" 2>/dev/null) == "$OMARCHY_VERSION" ]] && pass 'Omarchy version anchor' || warn 'Omarchy version differs from snapshot'
  [[ $(git -C "$HOME/.local/share/omarchy" rev-parse HEAD 2>/dev/null) == "$OMARCHY_REVISION" ]] && pass 'Omarchy revision anchor' || warn 'Omarchy revision differs from snapshot'
  [[ $(cat "$HOME/.config/omarchy/current/theme.name" 2>/dev/null) == "$THEME_NAME" ]] && pass 'Omarchy theme anchor' || fail 'Omarchy theme differs from snapshot'
  [[ $(uname -r) == "$KERNEL_RELEASE" ]] && pass 'kernel anchor' || warn 'kernel differs from snapshot'

  herdr_bin="$HOME/.local/bin/herdr"
  if [[ -x $herdr_bin ]]; then
    [[ $($herdr_bin --version 2>/dev/null) == "herdr $HERDR_VERSION" ]] && pass 'Herdr version anchor' || warn 'Herdr version differs from snapshot'
    [[ $(sha256sum "$herdr_bin" | cut -d' ' -f1) == "$HERDR_SHA256" ]] && pass 'Herdr checksum anchor' || warn 'Herdr checksum differs from snapshot'
  else
    fail 'Herdr binary missing'
  fi

  [[ $(git -C "$HOME/.config/zsh/plugins/zsh-autosuggestions" rev-parse HEAD 2>/dev/null) == "$ZSH_AUTOSUGGESTIONS_REVISION" ]] && pass 'zsh-autosuggestions revision' || fail 'zsh-autosuggestions revision drift'
  [[ $(git -C "$HOME/.config/zsh/plugins/fast-syntax-highlighting" rev-parse HEAD 2>/dev/null) == "$FAST_SYNTAX_HIGHLIGHTING_REVISION" ]] && pass 'fast-syntax-highlighting revision' || fail 'fast-syntax-highlighting revision drift'
fi

[[ $(xdg-mime query default text/html 2>/dev/null) == zen.desktop ]] && pass 'Zen HTML default' || fail 'Zen HTML default'
[[ $(xdg-mime query default inode/directory 2>/dev/null) == org.gnome.Nautilus.desktop ]] && pass 'Nautilus directory default' || fail 'Nautilus directory default'

zen_install_ini="$HOME/.config/zen/installs.ini"
if [[ -f $zen_install_ini ]]; then
  zen_profile=$(awk -F= '$1 == "Default" { print substr($0, index($0, "=") + 1); exit }' "$zen_install_ini")
  zen_profile_dir="$HOME/.config/zen/$zen_profile"
  zen_ok=true
  for zen_file in user.js zen-keyboard-shortcuts.json zen-themes.json chrome/zen-themes.css; do
    if [[ ! -f $zen_profile_dir/$zen_file ]] || ! cmp -s ".config/zen/$zen_file" "$zen_profile_dir/$zen_file"; then
      fail "Zen active-profile drift: $zen_file"
      zen_ok=false
    fi
  done
  [[ $zen_ok == true ]] && pass 'Zen active-profile mirrors'
else
  fail 'Zen installs.ini missing'
fi

printf '\nSummary: failures=%s warnings=%s\n' "$failures" "$warnings"
[[ $failures -eq 0 ]]
