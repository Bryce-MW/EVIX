#! /bin/bash
# NOTE(bryce): Written by Bryce Wilson a while ago and added to git on 2021-02-14.
#  * 2021-12-18|>Bryce|>Add alias for ip to add color

if command -v batcat &> /dev/null; then
  alias bat="batcat"
fi

if ! command -v bat &> /dev/null; then
  echo "Please install bat https://github.com/sharkdp/bat"
else
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

export EDITOR=nano

alias ip="ip -c"
alias commit="git add --all; git commit -m"
alias push="git push"
