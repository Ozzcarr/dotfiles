export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"

clone_if_missing() {
  local dest="$1" repo="$2"
  [[ -d "$dest" ]] || git clone --depth=1 "$repo" "$dest"
}

clone_if_missing "$ZSH" https://github.com/ohmyzsh/ohmyzsh.git
clone_if_missing "$ZSH_CUSTOM/plugins/zsh-autosuggestions" https://github.com/zsh-users/zsh-autosuggestions
clone_if_missing "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" https://github.com/zsh-users/zsh-syntax-highlighting

typeset -U path cdpath fpath manpath

DISABLE_AUTO_UPDATE="true"
export DISABLE_AUTO_TITLE="true"
ZSH_THEME=""

ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern regexp root line)

plugins=(
  history-substring-search
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

HISTSIZE="10000"

if [[ $options[zle] = on ]]; then
  source <(fzf --zsh)
fi

setopt HIST_FCNTL_LOCK
unsetopt EXTENDED_HISTORY
unsetopt HIST_EXPIRE_DUPS_FIRST

bindkey "\eh" backward-word
bindkey "\ej" down-line-or-history
bindkey "\ek" up-line-or-history
bindkey "\el" forward-word

bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

eval "$(zoxide init zsh --cmd cd)"

eval "$(direnv hook zsh)"

if [[ $TERM != "dumb" ]]; then
  eval "$(starship init zsh)"
fi

alias -- ..='cd ..'
alias -- ...='cd ../..'
alias -- ....='cd ../../..'
alias -- .....='cd ../../../..'
alias -- c=clear
alias -- cat=bat
alias -- eza='eza --icons auto --git --group-directories-first --no-quotes --header '\''--icons=always'\'' --classify --hyperlink=auto'
alias -- la='eza -lah '
alias -- ll='eza -lh --no-user --long'
alias -- lla='eza -la'
alias -- ls=eza
alias -- lt='eza --tree --level=2 --git-ignore'
alias -- lta='eza -a --tree --level=2 --git-ignore'
alias -- man=batman
alias -- ncg='nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot'
alias -- tree='eza --tree --git-ignore '
alias -- rb='nh os rollback'
alias -- claude-work='CLAUDE_CONFIG_DIR="$HOME/.claude-work" claude'

# Let Claude Code handle Ctrl+V, which also pastes images. See kitty.conf.
claude() {
  [[ -t 1 && -z "$TMUX" ]] && printf '\e]1337;SetUserVar=pass_ctrl_v=MQ==\a'
  command claude "$@"
}

if [[ -n "$KITTY_WINDOW_ID" && -z "$TMUX" ]]; then
  reset_pass_ctrl_v() { printf '\e]1337;SetUserVar=pass_ctrl_v\a' }
  precmd_functions+=(reset_pass_ctrl_v)
fi

frs() { nh os switch --hostname "$(hostname)" "$@" }
frb() { nh os boot --hostname "$(hostname)" "$@" }
fus() { nh os switch --hostname "$(hostname)" --update "$@" }
fub() { nh os boot --hostname "$(hostname)" --update "$@" }
hr() { nh home switch --configuration "oscar@$(hostname)" /home/oscar/nix-config "$@" }
