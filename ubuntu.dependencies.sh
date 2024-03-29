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

# Ensure apt repo dependencies are installed
sudo add-apt-repository ppa:neovim-ppa/unstable -y > /dev/null 2>&1
sudo apt-add-repository ppa:ansible/ansible -y > /dev/null 2>&1
# curl -sL "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x93C4A3FD7BB9C367" | sudo apt-key add

pushd ~ 2>&1 > /dev/null && \
  git clone https://github.com/techdufus/anime.git 2>&1 > /dev/null && \
  popd 2>&1 > /dev/null


echo -e "${CHECK_MARK}${GREEN} All apt repositories are added!${NC}"

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

echo -e "${ARROW}${GREEN} Installing new npm...${NC}"
sudo npm install -g n > /dev/null 2>&1
sudo n stable > /dev/null 2>&1
hash -r > /dev/null 2>&1


for dependency in "${DEPENDENCIES[@]}"; do
  if ! dpkg -s "$dependency" > /dev/null 2>&1; then
    echo -e "${ARROW}${YELLOW} Installing ${GREEN}$dependency${NC}"
    sudo nala install "$dependency" -y #> /dev/null 2>&1
  fi
done


# Install pip dependencies
PYTHON_DEPENDENCIES=(
  "pynvim"
)

for dependency in "${PYTHON_DEPENDENCIES[@]}"; do
  if ! pip3 list | grep "$dependency" > /dev/null 2>&1; then
    echo -e "${ARROW}${YELLOW} Installing ${GREEN}$dependency${NC}"
    pip3 install --user --upgrade pynvim > /dev/null 2>&1
  fi
done

# These commands need to be run after the dependencies are installed
#sudo chown -R $USER:$USER /usr/local/lib/node_modules > /dev/null 2>&1
# Inside nvim, run :PackerSync and :GoInstallBinaries
#sudo chown -R root:root /usr/local/lib/node_modules > /dev/null 2>&1


echo -e "${CHECK_MARK}${GREEN} All dependencies installed!${NC}"
