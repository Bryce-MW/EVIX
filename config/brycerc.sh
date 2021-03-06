#! /bin/bash
# NOTE(bryce): Written by Bryce Wilson a while ago and added to git on 2021-02-14.
#  * 2021-12-18|>Bryce|>Add alias for ip to add color
#  * 2021-04-16|>Bryce|>Add alias for ip for json

if command -v batcat &>/dev/null; then
  alias bat="batcat"
fi

if ! command -v bat &>/dev/null && ! command -v batcat &>/dev/null; then
  echo "Please install bat https://github.com/sharkdp/bat"
else
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

export EDITOR=nano

alias ip="ip -c"
alias ip-json="\ip -json"
alias commit="git add --all; git commit -m"
alias push="git push"
alias pull="git pull"
alias status="git status"
