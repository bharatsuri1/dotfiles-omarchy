# Omarchy dotfiles

Personal changes layered on top of the default Omarchy setup.

The repository is also being used to design a minimal Linux development-machine setup independent of Omarchy. See the [setup directions](docs/README.md), [first-install guides](docs/setup/README.md), and [decision ledger](docs/decisions.md).

The audited pre-Fedora reference machine, including its exact Omarchy revision,
hardware, services, package counts, upstream-versus-authored classification,
and privacy exclusions, is recorded in [the current host snapshot](docs/current-omarchy-host.md).

## Included

- **Bash** — aliases, Homebrew initialization, and Atuin Ctrl-R integration.
- **Zsh** — primary shell with XDG-based environment defaults, completion, history, FZF, Atuin, Zoxide, Starship, autosuggestions, and syntax highlighting.
- **Starship** — two-line prompt with the `` prompt character.
- **Atuin** — local fuzzy history search; daemon disabled.
- **Alacritty** — primary terminal override with the selected font and TUI key encodings.
- **Fcitx 5** — US keyboard input profile and notification settings.
- **Herdr** — UI, theme, and notification preferences.
- **Git** — portable defaults and public commit identity; authentication remains outside the repository.
- **Hyprland** — customized main config, idle behavior, input, scrolling layout, and application bindings.
- **Mise** — pinned Node.js runtime.
- **Packages** — Pacman restore lists, installed-version snapshot, orphan report, and a Homebrew bundle.
- **Portable assets** — selected wallpapers and the complete JetBrains Mono Nerd Font v3.5.0 archive with provenance and licensing notes.
- **Tmux** — Omarchy defaults with Zsh as the default shell.
- **XCompose/XDG directories** — identity compose sequences and portable home-directory roles.
- **Voxtype** — voice-to-text daemon configuration and user service.
- **Zen Browser** — default-browser associations, keyboard shortcuts, theme data/CSS, and portable preferences. Vimium is installed separately from the browser add-on store.

Files mirror their locations relative to `$HOME`, except the portable Zen files under `.config/zen/` must be placed in the active Zen profile directory.

## Restore

Review before copying because Omarchy and application updates may change their defaults.

```bash
cp .bash_profile .bashrc .zshenv .XCompose ~/
cp -r .config/alacritty .config/atuin .config/environment.d .config/fcitx5 .config/herdr .config/hypr ~/.config/
cp -r .config/mise .config/systemd .config/tmux .config/voxtype .config/zsh ~/.config/
cp .config/starship.toml .config/mimeapps.list .config/user-dirs.dirs ~/.config/
mkdir -p ~/.config/git && cp .config/git/config ~/.config/git/config
```

Install the official and foreign packages separately:

```bash
sudo pacman -S --needed - < packages-official-explicit.txt
yay -S --needed - < packages-foreign-explicit.txt
brew bundle --file ./Brewfile
mise install
```

Restore stock Omarchy-owned integrations, then select the captured theme:

```bash
omarchy-nvim-setup
omarchy theme set Catppuccin
omarchy-restart-xcompose
```

The restored `~/.zshenv` sets `ZDOTDIR` and loads `~/.config/zsh/.zshenv`; keep both files together. Install the Zsh plugins at the revisions used by this snapshot:

```bash
mkdir -p ~/.config/zsh/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.config/zsh/plugins/zsh-autosuggestions
git -C ~/.config/zsh/plugins/zsh-autosuggestions checkout 85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting ~/.config/zsh/plugins/fast-syntax-highlighting
git -C ~/.config/zsh/plugins/fast-syntax-highlighting checkout 3d574ccf48804b10dca52625df13da5edae7f553
chsh -s /usr/bin/zsh
```

Enable the restored user service:

```bash
systemctl --user daemon-reload
systemctl --user enable --now voxtype.service
```

Herdr remains the deliberate direct-upstream exception. Inspect its installer
before recreating the captured `~/.local/bin/herdr` binary:

```bash
curl -fsSLo /tmp/herdr-install.sh https://herdr.dev/install.sh
less /tmp/herdr-install.sh
sh /tmp/herdr-install.sh
herdr --version
```

For Zen, copy `user.js`, `zen-keyboard-shortcuts.json`, `zen-themes.json`, and `chrome/zen-themes.css` into the installation-selected profile shown by `~/.config/zen/profiles.ini`, then install Vimium.

## Installed additions

- Atuin
- Homebrew
- Dashlane CLI (Homebrew)
- Zsh
- Zen Browser (`zen-browser-bin`)
- Vimium (Zen extension)
