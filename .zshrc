ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

zinit wait lucid for \
  atinit"zicompinit; zicdreplay" \
      zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
      zsh-users/zsh-completions

zinit id-as"auto" for \
  atload"bindkey -e" \
      "https://git.sr.ht/~kareigu/zsh-utils/blob/main/editor/editor.plugin.zsh" \
  atload'eval "$(fzf --zsh)"' \
      "https://git.sr.ht/~kareigu/zsh-utils/blob/main/history/history.plugin.zsh" \

zstyle ':completion:*' menu yes select
unsetopt LIST_BEEP

export PATH=~/.cargo/bin/:$PATH
export PATH=~/.zig/:$PATH
export PATH=~/.local/bin:$PATH

eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"
export GPG_TTY=$(tty)
export EDITOR=nvim
export MANPAGER="sh -c 'col -xbf | bat -p -l man'"

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
