#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
MAGENTA='\033[1;35m'
YELLOW='\033[33m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

os="$(grep -m1 "NAME=" </etc/os-release | cut -d '"' -f 2)"
server="$(echo "$XDG_SESSION_TYPE")"

mainbanner () {
cat << EOF
                                             
▗▄▄▖       ▗▄▖                  █            
▐▛▀▜▌      █▀█                  ▀            
▐▌ ▐▌▗▟██▖▐▌ ▐▌▐▌ ▐▌ ▟██▖ █▟█▌ ██  ▐▌ ▐▌▐█▙█▖
▐███ ▐▙▄▖▘▐▌ ▐▌▐▌ ▐▌ ▘▄▟▌ █▘    █  ▐▌ ▐▌▐▌█▐▌
▐▌ ▐▌ ▀▀█▖▐▌ ▐▌▐▌ ▐▌▗█▀▜▌ █     █  ▐▌ ▐▌▐▌█▐▌
▐▙▄▟▌▐▄▄▟▌ █▄█▘▐▙▄█▌▐▙▄█▌ █   ▗▄█▄▖▐▙▄█▌▐▌█▐▌
▝▀▀▀  ▀▀▀  ▝▀█  ▀▀▝▘ ▀▀▝▘ ▀   ▝▀▀▀▘ ▀▀▝▘▝▘▀▝▘
             ▝                               
                                             
EOF
}

error () {
  >&2 printf "${RED}${BOLD}${@}${NC}${NORMAL}\n"
  exit 1
}

success () {
  printf "${GREEN}${@}${NC}\n"
}

info () {
  >&2 printf "${BLUE}${@}${NC}${NORMAL}\n"
}

warning () {
  >&2 printf "${GREEN}${@}${NC}${NORMAL}\n"
}

banner () {
  clear
  printf "${BLUE}${BOLD}$(mainbanner)${NC}${NORMAL}\n"
  echo -ne "${GREEN}┌─> ${NC}${YELLOW}By: ${MAGENTA}AlphaTechnolog${YELLOW} and ${MAGENTA}Bleyom ${NC}\n"
  echo -ne "${GREEN}├────────>${NC}${YELLOW} Links: ${BLUE}https://github.com/AlphaTechnolog${YELLOW} and ${BLUE}https://github.com/Bleyom\n"
  echo -ne "${GREEN}└────────>${NC}${YELLOW} The script only works for ${BLUE}Arch Linux${YELLOW} and ${GREEN}Void Linux${NC} ${RED}(Working in Debian and another distros support)${NC}\n"
}

check_deps () {
  info "Checking required dependencies"
  declare -a dependencies=('git')
  for dependency in ${dependencies[@]}; do
  if ! command -v $dependency 2>&1 > /dev/null; then
    error "Cannot found required dependency: $dependency"
  fi
  done
  banner
}

install_paru() {
  if ! pacman -Qs git base-devel fakeroot >/dev/null; then
    sudo pacman -S git base-devel fakeroot --noconfirm
  fi

  git clone https://aur.archlinux.org/paru-bin.git .paru-bin
  cd .paru-bin || exit 1
  makepkg -si
  cd ..
  rm -rf ./.paru-bin
}

check_server() {
  if [ "$server" == x11 ]; then
  echo -ne "${RED}[*] You are using X11${NC}"
  if [ "$os" == "Arch Linux" ]; then
    paru -Sy eww --noconfirm
  elif [ "$os" == "void" ]; then
    cp -r eww-template/eww srcpkgs/eww
  fi
  else
    echo -ne "${GREEN}[*] You are using Wayland or idk${NC}"
    if [ "$os" == "Arch Linux" ]; then
      paru -Sy eww-wayland-git --noconfirm
    elif [ "$os" == "void" ]; then
      cp -r eww-template/eww-wayland srcpkgs/eww
    fi
  fi
}

install_eww_x11 () {
  if [[ $os == 'Void' ]]; then
    if ! test -d ./eww-template/eww; then
      cp -r ./eww-template/eww ./srcpkgs/eww
    fi
  elif [[ $os == 'Arch Linux' ]]; then
    paru -Sy eww --noconfirm
  else
    warning "Cannot install eww for your operative system: skipping"
  fi
}

install_eww_wayland () {
  if [[ $os == 'Void' ]]; then
    if ! test -d ./eww-template/eww; then
      cp -r ./eww-template/eww-wayland ./srcpkgs/eww
    fi
  elif [[ $os == 'Arch Linux' ]]; then
    paru -Sy eww-wayland-git --noconfirm
  else
    warning "Cannot install eww for your operative system: skipping"
  fi
}

install_eww () {
  if [[ $server == "x11" ]]; then
    info "You are using X11"
    install_eww_x11
  else
    info "You are using Wayland or idk"
    install_eww_wayland
  fi
}

get_fixed_polybar_config () {
  printf "${BLUE}${NC}"
cat << EOF
[system-battery]
battery = BAT0
adapter = $(/bin/ls -1 /sys/class/power_supply)

[system-network]
interface = $(/bin/ls -1 /sys/class/net | grep w --color=never)
EOF
}

copy_config () {
  info "Copying config"
  cp -r ./.config/* $HOME/.config
  chmod +x $HOME/.config/bspwm/*
  chmod +x $HOME/.config/polybar/launch.sh
  get_fixed_polybar_config > $HOME/.config/polybar/system.ini
}

use_void () {
  info "Installing dependencies"
  sudo xbps-install xtools feh git polybar sxhkd bspwm rofi picom dunst neofetch kitty exa bat fish-shell wget unzip --yes
  info "Cloning void-packages and trying to install eww"
  if ! test -d void-packages; then
    git clone https://github.com/void-linux/void-packages.git void-packages
  fi
  cd void-packages || exit 1
  ./xbps-src binary-bootstrap
  if ! test -d eww-template; then
    git clone https://github.com/monke0192/eww-template
  fi
  install_eww
  ./xbps-src pkg eww
  cd ..
  xi eww
  copy_config
}

use_common () {
  skip_auto_dependencies_installation
  copy_config
}

use_arch () {
  if ! command -v paru 2>&1 > /dev/null; then
    info "Paru not found: installing!"
    install_paru
  fi
  paru -Sy polybar git sxhkd bspwm polybar feh rofi picom dunst neofetch nerd-fonts-ttf kitty bat exa fish wget unzip --noconfirm
  install_eww
  copy_config
}

skip_auto_dependencies_installation () {
  warning "Cannot get a valid operative system to autoinstall the dependencies: skipping!"
}

start_installation () {
  if [[ $os == 'Void' ]]; then
    use_void
  elif [[ $os == 'Arch Linux' ]]; then
    use_arch
  else
    use_common
  fi
}

install_fonts () {
  font_name='Iosevka'
  font_url='https://github.com/ryanoasis/nerd-fonts/releases/download/2.2.0-RC/Iosevka.zip'
  info "Downloading font '$font_name' from '$font_url'"
  wget "$font_url"
  if ! test -f "$font_name.zip"; then
    error "Cannot download font... try manually downloading it from the url"
  fi
  mkdir -p ./$font_name
  mv "$font_name.zip" $font_name
  cd $font_name
  unzip "$font_name.zip"
  sudo mv ./*.ttf /usr/share/fonts
  cd ../
  rm -rf ./$font_name
  info "Reloading fonts cache"
  fc-cache -r
  success "Font downloaded & installed successfully"
}

main () {
  banner
  check_deps
  start_installation
  install_fonts
}

main
