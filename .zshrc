export ZSH=~/.oh-my-zsh
export PATH=~/.cargo/bin/:$PATH
export PATH=~/.zig/:$PATH
export PATH=~/.local/bin:$PATH



autoload bashcompinit
bashcompinit
source ~/.config/helix/contrib/completion/hx.zsh

ZSH_THEME="robbyrussell"
plugins=(git colorize zsh-interactive-cd rust docker-compose zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"
export GPG_TTY=$(tty)
export EDITOR=nvim

# git
alias gs="git status"
alias gap="git add -p"
alias gpl="git pull"
alias gp="git push"
alias gc="git commit"


alias ls="lsd"
