#!/usr/bin/env zsh
# Shell aliases for workflow utilities
# Source this file from your .zshrc with: source /path/to/file

# Navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# List directory contents
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gl='git log --oneline --graph --decorate'
alias gla='git log --oneline --graph --decorate --all'

git-local-branch-prune() {
  git fetch -p && git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -d
}

git-local-branch-prune-force() {
  git fetch -p && git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D
}

# Safe file operations
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Utilities
alias c='clear'
alias h='history'
alias grep='grep --color=auto'
alias mkdir='mkdir -p'

# System
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Network
alias ping='ping -c 5'
alias ports='netstat -tulanp'

# Development
alias py='python3'
alias pip='pip3'
alias serve='python3 -m http.server'
alias json='python3 -m json.tool'

# Docker (if you use it)
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'

# Custom functions
# Quick find
function qf() {
    find . -name "*$1*"
}

# Make and change directory
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract archives
function extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"    ;;
            *.tar.gz)    tar xzf "$1"    ;;
            *.bz2)       bunzip2 "$1"    ;;
            *.rar)       unrar x "$1"    ;;
            *.gz)        gunzip "$1"     ;;
            *.tar)       tar xf "$1"     ;;
            *.tbz2)      tar xjf "$1"    ;;
            *.tgz)       tar xzf "$1"    ;;
            *.zip)       unzip "$1"      ;;
            *.Z)         uncompress "$1" ;;
            *.7z)        7z x "$1"       ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
