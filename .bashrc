# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
alias c='clear'
alias l='eza -lah --group-directories-first --icons=auto'
alias ll='eza -lah --group-directories-first --icons=auto'
alias la='eza -a --group-directories-first --icons=auto'

if command -v atuin &>/dev/null; then
  eval "$(atuin init bash --disable-up-arrow)"
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
