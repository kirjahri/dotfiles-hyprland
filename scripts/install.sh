#!/bin/bash

is_installed() {
  package="$1"

  for package; do
    if pacman -Qi "$package" > /dev/null; then
      return 0
    fi

    return 1
  done
}

install_packages() {
  uninstalled_packages=()

  for package; do
    if is_installed "$package"; then
      echo ":: $package is already installed"
      continue
    fi

    uninstalled_packages+=("$package")
  done

  [ -z "${uninstalled_packages[@]}" ] && return

  echo "The following packages will be installed:"
  printf "  %s\n" "${uninstalled_packages[@]}"
  sudo pacman --noconfirm -S "${uninstalled_packages[@]}"
}

command_exists() {
  command="$1"

  if command -v "$command" > /dev/null; then
    return 0
  else
    return 1
  fi
}

install_yay() {
  script_path="$(realpath $0)"
  temp_path="$(dirname $script_path)"
  install_path="$HOME/yay"
  needed_packages=("git" "base-devel")

  install_packages "${needed_packages[@]}"

  git clone https://aur.archlinux.org/yay.git "$install_path"
  cd "$install_path"
  makepkg -si
  echo ":: yay has been installed successfully"

  cd "$temp_path"
}

DOTFILES_DIR="$HOME/dotfiles-hyprland"

hyprland_packages=(
  "hyprland"
  "xdg-desktop-portal-hyprland"
  "hyprpaper"
  "hypridle"
  "hyprlock"
  "noto-fonts"
  "noto-fonts-emoji"
  "noto-fonts-cjk"
  "noto-fonts-extra"
  "libnotify"
  "kitty"
  "qt5-wayland"
  "qt6-wayland"
  "uwsm"
)
packages=(
  "brightnessctl"
  "playerctl"
  "polkit-kde-agent"
  "dolphin"
  "qt5ct"
  "qt6ct"
  "waybar"
  "otf-font-awesome"
  "ttf-hack"
  "ttf-ibmplex-mono-nerd"
  "pavucontrol"
  "network-manager-applet"
  "blueman"
  "rofi"
  "rofimoji"
  "cliphist"
  "hyprshot"
  "wlogout"
  "gtk3"
  "gtk4"
  "nwg-look"
  "breeze-icons"
  "adwaita-icon-theme"
  "ungoogled-chromium-bin"
  "webcord"
  "spotify-launcher"
  "stow"
) # I'm so forgetting something but it's actually whatever

clear

cat << "EOF"
  ____       _
 / ___|  ___| |_ _   _ _ __
 \___ \ / _ \ __| | | | '_ \
  ___) |  __/ |_| |_| | |_) |
 |____/ \___|\__|\__,_| .__/
                      |_|

EOF

echo ":: Synchronizing package databases..."
sudo pacman -Sy

echo ":: Installing yay..."
if command_exists "yay"; then
  echo ":: yay is already installed"
else
  install_yay
fi

cat << "EOF"
  ___           _        _ _
 |_ _|_ __  ___| |_ __ _| | |
  | || '_ \/ __| __/ _` | | |
  | || | | \__ \ || (_| | | |
 |___|_| |_|___/\__\__,_|_|_|

EOF

read -p "Would you like to continue with the installation process? [Y/n]: " yn
case $yn in
  [Nn]*)
    echo "Aborting installation process..."
    exit
    ;;
  *)
    ;;
esac

echo ":: Installing Hyprland packages..."
install_packages "${hyprland_packages[@]}"

echo ":: Installing other packages..."
install_packages "${packages[@]}"

fc-cache -f -v # updates font cache

echo ":: Cloning dotfiles GitHub repository"
if [ -d "$DOTFILES_DIR" ]; then
  echo "The dotfiles directory ($DOTFILES_DIR) already exists and must be deleted in order to continue"
  read -p "Would you like to delete it the existing dotfiles directory? [y/N]: " yn
  case $yn in
    [Yy]*)
      rm -rf "$DOTFILES_DIR"
      ;;
    *)
      echo "Aborting installation process..."
      exit
      ;;
  esac
else
  git clone "https://github.com/kirjahri/dotfiles-hyprland.git" "$DOTFILES_DIR"
fi

echo ":: Changing into dotfiles directory..."
cd "$DOTFILES_DIR"

echo "WARNING: Any existing files in the '~/.config' directory that interfere will be overwritten"
read -p "Are you sure you want to continue? [y/N]: " yn
case $yn in
  [Yy]*)
    ;;
  *)
    echo "Aborting installation process..."
    exit
    ;;
esac

echo ":: Symlinking configuration files..."
stow --adopt .
git pull origin main # the --adopt flog on stow overwrites the files in the dotfiles folder so this is done in order to restore them

systemctl --user enable "$HOME/.config/systemd/user/low-battery.timer"

# Find and give execute permissions to all shell scripts
find "$DOTFILES_DIR/scripts" -type f -exec chmod u+x {} \;

cat << "EOF"
  ____           _       ___           _        _ _
 |  _ \ ___  ___| |_    |_ _|_ __  ___| |_ __ _| | |
 | |_) / _ \/ __| __|____| || '_ \/ __| __/ _` | | |
 |  __/ (_) \__ \ ||_____| || | | \__ \ || (_| | | |
 |_|   \___/|___/\__|   |___|_| |_|___/\__\__,_|_|_|

EOF

echo "A reboot must be done in order to ensure that all configurations are working correctly"
read -p "Would you like to reboot your system? [Y/n]: " yn
case $yn in
  [Nn]*)
    ;;
  *)
    echo ":: Rebooting..."
    systemctl reboot
    ;;
esac
