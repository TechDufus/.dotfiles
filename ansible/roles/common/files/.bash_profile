

alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y'
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

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ [\1]/'
}

k8s_info() {
  kubectl config view --minify --output 'jsonpath={..namespace}@{.current-context}' 2> /dev/null
}

## Customizations
PS1="\[\e[1;92m\][\w]\[\e[33m\]\$(parse_git_branch) \[\e[01;33m\][\$(k8s_info)]\[\e[34m\] $>\[\e[96m\] "

