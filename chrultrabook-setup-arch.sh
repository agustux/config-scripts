#!/bin/bash

# Setting Bools:
if lscpu | grep -iq "intel"; then
  IS_INTEL=true
fi
if cat /proc/cpuinfo | grep -iq "vmx" || grep -iq "svm"; then
  VIRT_ACCEL=true
fi
if lsusb | grep -iq "finger"; then
  FP_PRESENT=true
fi

# Upgrading all:
sudo pacman -Syu --noconfirm

# Installing yay (AUR helper):
sudo pacman -Sy --needed --noconfirm git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
cd ../ && rm -rf yay/

# Removing bloat:
sudo pacman -Rns --noconfirm gnome-software gnome-calendar gnome-text-editor gnome-maps gnome-contacts gnome-connections gnome-weather gnome-characters gnome-tour gnome-logs gnome-font-viewer gnome-remote-desktop gnome-user-docs yelp orca brltty epiphany malcontent simple-scan nano

# Installing misc. packages:
yay -S --needed --noconfirm curl vim less jq man ufw rsync powertop nvtop zip lm_sensors vlc vlc-plugins-all p7zip cpupower extension-manager update-grub brave-bin steam neovim ghostty fastfetch bat #proton-vpn-gtk-app windscribe-v2-bin

# Installing intel-specific packages:
if $IS_INTEL; then
  yay -S --noconfirm intel-gpu-tools intel-undervolt
fi

# virt-manager dependencies
if $VIRT_ACCEL; then
  sudo pacman -Sy --noconfirm virt-manager libvirt libvirt-dbus qemu-full
  sudo usermod -aG libvirt $(whoami)
  sudo usermod -aG libvirt-qemu $(whoami)
  sudo systemctl enable --now libvirtd
  sudo systemctl enable virtlogd.socket
  sudo systemctl restart libvirtd.service
fi

# Fingerprint packages:
if $FP_PRESENT; then
  sudo pacman -Sy --noconfirm fprintd
  fprintd-enroll
  sudo bash -c 'sed "1a auth            sufficient      pam_fprintd.so" /etc/pam.d/sudo > /etc/pam.d/sudo-temp && mv /etc/pam.d/sudo-temp /etc/pam.d/sudo'
fi

# GRUB parameters:
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 intel_iommu=on iommu=pt"/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# UFW enable:
sudo ufw enable

# Sensors (temp support):
sudo sensors-detect --auto
# sensors | grep Core

# Randomizing MAC address:
sudo tee /etc/NetworkManager/conf.d/mac-randomize.conf > /dev/null <<EOF
[device-mac-randomization]
wifi.scan-rand-mac-address=yes

[connection-mac-randomization]
ethernet.cloned-mac-address=random
wifi.cloned-mac-address=random
EOF
sudo chmod 0644 /etc/NetworkManager/conf.d/mac-randomize.conf

# Configuring ghostty
echo '
window-height=33
window-width=130

keybind = unconsumed:ctrl+k=goto_split:top
keybind = unconsumed:ctrl+j=goto_split:bottom
keybind = unconsumed:ctrl+h=goto_split:left
keybind = unconsumed:ctrl+l=goto_split:right
' >> $HOME/.config/ghostty/config

# Configuring powertop on startup:
sudo tee /etc/systemd/system/powertop-settings.service > /dev/null <<EOF
[Unit]
Description=Enablind "good" powertop settings
After=multi-user.target
[Service]
Type=oneshot
ExecStart=/usr/bin/powertop-settings.sh
RemainAfterExit=true
[Install]
WantedBy=multi-user.target
EOF
sudo chmod 644 /etc/systemd/system/powertop-settings.service
sudo tee /usr/bin/powertop-settings.sh > /dev/null <<EOF
#!/bin/bash
sudo powertop --auto-tune
EOF
sudo chmod 755 /usr/bin/powertop-settings.sh
sudo systemctl enable --now powertop-settings.service

# Audio patches (for chromebooks)
git clone --depth 1 https://github.com/WeirdTreeThing/chromebook-linux-audio
cd chromebook-linux-audio
./setup-audio
cd $HOME

# Keyboard remap (for chromebooks)
git clone https://github.com/WeirdTreeThing/cros-keyboard-map
cd cros-keyboard-map
./install.sh
cd $HOME

# Installing Sublime
# curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
# echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
# sudo pacman -Syu sublime-text --noconfirm

# GNOME preferences
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'interactive'
gsettings set org.gnome.desktop.peripherals.touchpad disable-while-typing false
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
# dconf write /org/gnome/shell/extensions/Bluetooth-Battery-Meter/enable-airpods-device true

# Purging any orphaned packages:
yay -Rns $(yay -Qtdq) --noconfirm
yay -Scc --noconfirm


# Waydroid Stuff:
# yay -Sy --needed --noconfirm binder_linux-dkms python-pyclip wl-clipboard
# sudo modprobe binder-linux devices=binder,hwbinder,vndbinder
# sudo echo "binder_linux" > /etc/modules-load.d/binder_linux.conf
# sudo echo "options binder_linux devices=binder,hwbinder,vndbinder" > /etc/modprobe.d/binder_linux.conf
# might need kernel param: ibt=off if seg-fault happens

# yay -S --needed --noconfirm waydroid 
# sudo waydroid init -s GAPPS
# sudo systemctl enable --now waydroid-container.service
# waydroid status
# sudo waydroid shell and get the ID
#
# if android audio doesn't work: 
# sudo pacman -S --needed --noconfirm pipewire-pulse
# systemctl --user restart dbus.service
# systemctl --user enable --now pipewire wireplumber pipewire-pulse
# sudo ufw allow 67
# sudo ufw allow 53

# for integration with desktop windows:
# waydroid session start
# waydroid prop set persist.waydroid.multi_windows true
# waydroid session stop
# waydroid session start

# sudo waydroid-extras and choose to install libndk from the menu to get ARM app support

