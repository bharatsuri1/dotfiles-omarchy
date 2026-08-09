HISTFILE="$HOME/.local/state/zsh/history"
HISTSIZE=50000
SAVEHIST=50000

setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE AUTO_CD INTERACTIVE_COMMENTS NO_BEEP

autoload -Uz compinit
if [[ ! -s "$HOME/.cache/zsh/zcompdump" ]] || [[ -n "$(find "$HOME/.cache/zsh/zcompdump" -mtime +1 -print -quit 2>/dev/null)" ]]; then
  compinit -d "$HOME/.cache/zsh/zcompdump"
else
  compinit -C -d "$HOME/.cache/zsh/zcompdump"
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

alias c='clear'
alias l='eza -lah --group-directories-first --icons=auto'
alias ll='eza -lah --group-directories-first --icons=auto'
alias la='eza -a --group-directories-first --icons=auto'
alias cat='bat'
alias grep='rg --color=auto'

source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
source "$ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$ZDOTDIR/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

eval "$(zoxide init zsh)"
eval "$(atuin init zsh --disable-up-arrow)"
eval "$(starship init zsh)"
