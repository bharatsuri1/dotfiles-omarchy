# Fonts

This directory contains portable font releases selected for the Linux desktop
and development environment. Keep each release's upstream documentation and
license beside its font files.

## JetBrains Mono Nerd Font

`JetBrainsMono/` is the complete JetBrains Mono archive from Nerd Fonts v3.5.0.
It contains the regular and no-ligature families in standard, strict-monospace,
and proportional variants, with all supplied static weights and italics. The
patched font is based on JetBrains Mono 2.304 and is distributed under the SIL
Open Font License 1.1 included in `JetBrainsMono/OFL.txt`.

Install the complete collection for the current user from the repository root:

```bash
install -d ~/.local/share/fonts/JetBrainsMonoNerd
find assets/fonts/JetBrainsMono -maxdepth 1 -type f -name '*.ttf' \
  -exec install -m 0644 {} ~/.local/share/fonts/JetBrainsMonoNerd/ \;
fc-cache -f
fc-match 'JetBrainsMono Nerd Font'
```

Source: [Nerd Fonts v3.5.0](https://github.com/ryanoasis/nerd-fonts/releases/tag/v3.5.0).
