ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

if [ -x "$(which jj)" ]; then
  JJ_INSTALLED="$(which jj)"
fi

zinit wait lucid for \
  atinit"zicompinit; zicdreplay" \
      zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
  atload"if [ -v JJ_INSTALLED ]; then; source <(jj util completion zsh); fi" \
  atload"if [ -v JJ_INSTALLED ]; then; source <(COMPLETE=zsh jj); fi" \
      zsh-users/zsh-completions

zinit id-as"auto" for \
  atload"bindkey -e" \
      "https://git.sr.ht/~kareigu/zsh-utils/blob/main/editor/editor.plugin.zsh" \
  atload'eval "$(fzf --zsh)"' \
      "https://git.sr.ht/~kareigu/zsh-utils/blob/main/history/history.plugin.zsh" \

zstyle ':completion:*' menu yes select
unsetopt LIST_BEEP

export PATH=~/.cargo/bin/:$PATH
export PATH=~/.zvm/bin:$PATH
export PATH=~/.local/bin:$PATH

if [ -x "$(which starship)" ]; then
  eval "$(starship init zsh)"
else
  echo "starship not in path"
fi

if [ -x "$(which zoxide)" ]; then
  eval "$(zoxide init zsh --cmd cd)"
else
  echo "zoxide not in path"
fi

export GPG_TTY=$(tty)

if [ -x "$(which nvim)" ]; then
  export EDITOR='nvim'
elif [ -x "$(which vim)" ]; then
  export EDITOR='vim'
else
  export EDITOR='vi'
fi

if [ -x "$(which batman)" ]; then
    eval "$(batman --export-env)"
fi

# git
alias gs="git status"
alias gap="git add -p"
alias gpl="git pull"
alias gp="git push"
alias gc="git commit"
alias lzg=lazygit


alias ls="lsd"
alias l="ls -la"
alias la="ls -lA"
