# Omarchy dotfiles

Personal changes layered on top of the default Omarchy setup.

## Included

- **Bash** — aliases, Homebrew initialization, and Atuin Ctrl-R integration.
- **Starship** — two-line prompt with the `` prompt character.
- **Atuin** — local fuzzy history search; daemon disabled.
- **Hyprland** — customized `hyprland.conf`, `hypridle.conf`, and `input.conf`.
- **Zen Browser** — default-browser associations, keyboard shortcuts, theme data/CSS, and portable preferences. Vimium is installed separately from the browser add-on store.

Files mirror their locations relative to `$HOME`, except the portable Zen files under `.config/zen/` must be placed in the active Zen profile directory.

## Restore

Review before copying because Omarchy and application updates may change their defaults.

```bash
cp .bashrc ~/
cp -r .config/atuin .config/hypr ~/.config/
cp .config/starship.toml .config/mimeapps.list ~/.config/
```

For Zen, copy `user.js`, `zen-keyboard-shortcuts.json`, `zen-themes.json`, and `chrome/zen-themes.css` into the active profile shown by `~/.config/zen/profiles.ini`, then install Vimium.

## Installed additions

- Atuin
- Homebrew
- Dashlane CLI (Homebrew)
- Zen Browser (`zen-browser-bin`)
- Vimium (Zen extension)
