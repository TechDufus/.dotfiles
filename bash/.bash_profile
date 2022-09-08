
#color codes
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE="\\033[38;5;27m"
SEA="\\033[38;5;49m"
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'

#emoji codes
CHECK_MARK="${GREEN}\xE2\x9C\x94${NC}"
X_MARK="${RED}\xE2\x9C\x96${NC}"
PIN="${RED}\xF0\x9F\x93\x8C${NC}"
CLOCK="${GREEN}\xE2\x8C\x9B${NC}"
ARROW="${SEA}\xE2\x96\xB6${NC}"
BOOK="${RED}\xF0\x9F\x93\x8B${NC}"
HOT="${ORANGE}\xF0\x9F\x94\xA5${NC}"
WARNING="${RED}\xF0\x9F\x9A\xA8${NC}"
RIGHT_ANGLE="${GREEN}\xE2\x88\x9F${NC}"

alias update='sudo nala update && sudo nala upgrade -y && sudo nala autoremove -y'
alias k=kubectl
alias kgp='kubectl get pods'
alias kgs='kubectl get service'
alias kga='kubectl get all'
alias kgn='kubectl get nodes -o wide'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias ka='kubectl apply'
alias kexec='kubectl exec'
alias v=vagrant
alias gs='git status'
alias vi='nvim'
alias vim='nvim'
alias ni='nvim'
# alias ll='ls -la'
alias ll='ls -alFh'

gacp() {
  git add -A
  git commit -m "$*"
  git push -u origin $(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
}

ggl() {
  git log --oneline --graph
}

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ [\1]/'
}

k8s_info() {
  kubectl config view --minify --output 'jsonpath={..namespace}@{.current-context}' 2> /dev/null
}

export PATH="$HOME/.local/bin:$PATH"
PATH=$PATH:/usr/local/go/bin:"$HOME/go/bin"

## Customizations
PS1="\[\e[1;92m\][\w]\[\e[33m\]\$(parse_git_branch) \[\e[01;33m\][\$(k8s_info)]\[\e[34m\] $>\[\e[96m\] "


