if ! command -v bat &> /dev/null; then
  echo "Please install bat https://github.com/sharkdp/bat"
else
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

export EDITOR=nano
