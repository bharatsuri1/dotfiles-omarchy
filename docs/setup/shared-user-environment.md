# Shared user and development environment

Run this after the selected desktop profile works. Commands are separated by distribution where package names differ.

## 1. Install native development packages

Arch:

```bash
sudo pacman -S --needed \
  base-devel git github-cli lazygit neovim \
  zsh tmux starship atuin zoxide bat btop fzf ripgrep fd eza \
  mise uv podman podman-compose stow restic curl wget unzip
```

Fedora:

```bash
sudo dnf group install development-tools
sudo dnf install \
  git gh neovim \
  zsh tmux starship atuin zoxide bat btop fzf ripgrep fd-find eza \
  mise uv podman podman-compose stow restic curl wget unzip
```

Do not install Docker Engine, `docker-compose`, or `podman-docker`.

## 2. Set Zsh as the interactive shell

```bash
command -v zsh
chsh -s "$(command -v zsh)"
```

Log out and back in before testing login-shell behavior. Bash and POSIX sh remain installed for scripts.

The final Stow package will own Zsh, Starship, Alacritty, tmux, Atuin, Mise, Git defaults, and application configuration. Until that package is added, do not copy the legacy Omarchy repository root wholesale onto the new system.

## 3. Install pinned Zsh plugins

```bash
mkdir -p ~/.config/zsh/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ~/.config/zsh/plugins/zsh-autosuggestions
git -C ~/.config/zsh/plugins/zsh-autosuggestions \
  checkout 85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting \
  ~/.config/zsh/plugins/fast-syntax-highlighting
git -C ~/.config/zsh/plugins/fast-syntax-highlighting \
  checkout 3d574ccf48804b10dca52625df13da5edae7f553
```

Load them directly from `.zshrc` after native `compinit`; do not add a shell framework or plugin manager.

## 4. Install LazyVim

Back up an existing Neovim configuration before this command. For a fresh account:

```bash
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
nvim
```

The first run installs plugins. Later, move reviewed text configuration into the Stow package; never commit plugin caches or authentication state.

## 5. Add Flathub and Zen Browser

```bash
flatpak remote-add --if-not-exists flathub \
  https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub app.zen_browser.zen
xdg-settings set default-web-browser app.zen_browser.zen.desktop
```

Validate downloads, file chooser, external links, audio/video, and PipeWire screen sharing. Do not install a second Zen package.

## 6. Install Homebrew and Dashlane CLI

Download and inspect the official installer before running it:

```bash
curl -fsSLo /tmp/homebrew-install.sh \
  https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
less /tmp/homebrew-install.sh
/bin/bash /tmp/homebrew-install.sh
```

On Linux, keep the supported prefix and initialize it from Zsh configuration:

```bash
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install dashlane/tap/dashlane-cli
dcli --version
```

Fedora does not package lazygit in its official repositories, so install the selected Git TUI through Homebrew on Fedora only:

```bash
# Fedora only
brew install lazygit
```

Arch keeps lazygit under pacman ownership. Homebrew owns only these explicitly approved formulae; do not use it to duplicate native packages.

## 7. Install Herdr from upstream

Download and inspect the installer, then let it place the verified release binary in `~/.local/bin`:

```bash
curl -fsSLo /tmp/herdr-install.sh https://herdr.dev/install.sh
less /tmp/herdr-install.sh
sh /tmp/herdr-install.sh
~/.local/bin/herdr --version
```

Herdr updates with `herdr update`. It is the deliberate direct-upstream binary exception; do not also install it through Homebrew.

## 8. Configure Git and GitHub interactively

```bash
git config --global user.name 'YOUR NAME'
git config --global user.email 'YOUR EMAIL'
ssh-keygen -t ed25519 -a 64 -C 'YOUR EMAIL'
gh auth login
```

Choose GitHub.com, SSH, and upload the new public key when prompted. Prefer SSH remote URLs. Do not put private keys, tokens, or a hardcoded personal identity in Stow.

## 9. Install VS Code on Fedora only

Arch skips VS Code in v1. On Fedora, install Microsoft's repository configuration explicitly:

```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudoedit /etc/yum.repos.d/vscode.repo
```

Enter:

```ini
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
```

Then:

```bash
sudo dnf install code
```

Keep Settings Sync disabled in v1. Record only a reviewed extension list and text settings later.

## 10. Validate runtimes and containers

Mise owns non-Python runtimes; uv owns Python:

```bash
mise use --global node@latest
node --version
uv python install
mkdir -p /tmp/uv-smoke
cd /tmp/uv-smoke
uv init
uv run python -c 'print("uv works")'
```

Validate rootless Podman and the selected provider:

```bash
podman info
podman run --rm docker.io/library/alpine:latest echo 'podman works'
podman compose version
```

Do not run `mise self-update` or `uv self update`; their executables are package-manager-owned.

## 11. Configure manual Restic backup

Export the repository location and credentials only in the current shell, preferably injected by Dashlane:

```bash
export RESTIC_REPOSITORY='YOUR_REPOSITORY'
restic snapshots
restic backup ~/Documents ~/Projects
restic check
```

Perform a representative restore into a temporary directory before trusting the backup. Do not commit the destination, password, cloud keys, or generated environment files. Automatic timers remain outside v1.

## 12. Update ownership

Use each selected owner explicitly:

```bash
# Arch
sudo pacman -Syu

# Fedora
sudo dnf upgrade --refresh

flatpak update
brew update
brew upgrade
mise upgrade
uv tool upgrade --all
herdr update
```

Review failures rather than hiding these commands in one opaque update script. Reboot after kernel, firmware, graphics, or critical library changes and rerun the relevant smoke tests.

## References

- [uv installation and package-manager update behavior](https://docs.astral.sh/uv/getting-started/installation/)
- [Mise installation](https://mise.jdx.dev/installing-mise.html)
- [Homebrew on Linux](https://docs.brew.sh/Homebrew-on-Linux)
- [lazygit Homebrew formula](https://formulae.brew.sh/formula/lazygit)
- [Zen on Flathub](https://flathub.org/apps/app.zen_browser.zen)
- [VS Code on Fedora](https://code.visualstudio.com/docs/setup/linux)
- [LazyVim installation](https://www.lazyvim.org/installation)
