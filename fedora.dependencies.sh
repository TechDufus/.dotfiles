#!/usr/bin/env bash

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



DEPENDENCIES=(
  "git"
  "curl"
  "wget"
  "vim"
  "ansible"
  "ansible-lint"
  "python3"
  "python3-pip"
  "terraform"
  "stow"
  "neovim"
  "fzf"
  "npm"
  "ripgrep"
  "fd-find"
  "gopls"
)



for dependency in "${DEPENDENCIES[@]}"; do
  if ! dpkg -s "$dependency" > /dev/null 2>&1; then
    echo -e "${ARROW}${YELLOW} Installing ${GREEN}$dependency${NC}"
    sudo nala install "$dependency" -y #> /dev/null 2>&1
  fi
done

