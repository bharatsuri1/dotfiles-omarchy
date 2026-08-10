#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

pacman -Q | LC_ALL=C sort > "$tmp_dir/packages-all-with-versions.txt"
pacman -Qqe | LC_ALL=C sort > "$tmp_dir/packages-explicit.txt"
pacman -Qqen | LC_ALL=C sort > "$tmp_dir/packages-official-explicit.txt"
pacman -Qqem | LC_ALL=C sort > "$tmp_dir/packages-foreign-explicit.txt"
pacman -Qdt | LC_ALL=C sort > "$tmp_dir/packages-orphans-with-versions.txt"

combined_count=$(( $(wc -l < "$tmp_dir/packages-official-explicit.txt") + $(wc -l < "$tmp_dir/packages-foreign-explicit.txt") ))
explicit_count=$(wc -l < "$tmp_dir/packages-explicit.txt")
if [[ $combined_count -ne $explicit_count ]]; then
  printf 'Manifest reconciliation failed: explicit=%s official+foreign=%s\n' "$explicit_count" "$combined_count" >&2
  exit 1
fi

for file in "$tmp_dir"/packages-*.txt; do
  install -m 0644 "$file" "$repo_root/${file##*/}"
done

if [[ ${1:-} == --brew ]]; then
  brew_bin=$(command -v brew || true)
  [[ -n $brew_bin ]] || brew_bin=/home/linuxbrew/.linuxbrew/bin/brew
  [[ -x $brew_bin ]] || { printf 'brew executable not found\n' >&2; exit 1; }
  HOMEBREW_NO_AUTO_UPDATE=1 "$brew_bin" bundle dump --force --file "$repo_root/Brewfile"
fi

printf 'Refreshed manifests: installed=%s explicit=%s official=%s foreign=%s orphans=%s\n' \
  "$(wc -l < "$repo_root/packages-all-with-versions.txt")" \
  "$(wc -l < "$repo_root/packages-explicit.txt")" \
  "$(wc -l < "$repo_root/packages-official-explicit.txt")" \
  "$(wc -l < "$repo_root/packages-foreign-explicit.txt")" \
  "$(wc -l < "$repo_root/packages-orphans-with-versions.txt")"
