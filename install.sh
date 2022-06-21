###
 # @Copyright: xvsos
 # @Author: xvs
 # @Date: 2022-06-20 09:25:51
 # @LastEditTime: 2022-06-21 22:14:20
 # @LastEditors: OsenbergQu
 # @FilePath: /xvsos-installer/install.sh
 # @Description: 
### 
#! /bin/sh

user=xs
home=/home/$user

config_pkg_source() {
  dir="/usr/local/etc/pkg/repos"
  mkdir -p  $dir
  echo "FreeBSD: {" >> $dir/FreeBSD.conf
  echo "  url: \"pkg+http://mirrors.ustc.edu.cn/freebsd-pkg/\${ABI}/latest\"" >> $dir/FreeBSD.conf
  # echo "  url: \"pkg+http://mirrors.ustc.edu.cn/freebsd-pkg/${ABI}/quarterly\""
  echo "}" >> $dir/FreeBSD.conf

  pkg update -f

  # update ports
  portsnap fetch
  portsnap extract
  portsnap fetch update
}

config_ports_source() {
  echo "MASTER_SITE_OVERRIDE?=http://mirrors.ustc.edu.cn/freebsd-ports/distfiles/\${DIST_SUBDIR}/" >> /etc/make.conf
}

install_system_env() {
  # install pkg
  # cd /usr/ports/ports-mgmt/pkg; make; make install clean
  # sudo
  pkg install sudo
  echo "$user ALL=(ALL) ALL" >> /usr/local/etc/sudoers

}

config_desktop_common() {
  # zsh, oh-my-zsh
  sudo pkg install zsh
  chsh -s /usr/local/bin/zsh

  sudo pw groupmod video -m $user
  sudo pkg install wayland seatd dbus drm-fbsd13-kmod libva-intel-driver git
  sudo sysrc seatd_enable="YES"
  sudo sysrc dbus_enable="YES"
  sudo sysrc kld_list+=i915kms

  git clone https://gitee.com/mirrors/oh-my-zsh.git $home/.oh-my-zsh
  cp ./zshrc.zsh-template $home/.zshrc

  mkdir -p $home/.config/runtime
  echo "export XDG_RUNTIME_DIR=\$HOME/.config/runtime" >> $home/.zshrc
}

config_desktop_sway() {
  sudo pkg install sway swayidle swaylock-effects alacritty wofi
  mkdir $home/.config/sway
  #cp /usr/local/etc/sway/config $home/.config/sway
  cp ./sway/config $home/.config/sway
}

config_desktop_wayfire() {
  sudo pkg install wayfire wf-shell alacritty swaylock-effects swayidle wlogout kanshi mako wlsunset wofi
  #cp /usr/local/etc/sway/config $home/.config/sway
  cp ./wayfire.ini $home/.config/wayfire.ini
  cp ./wf-shell.ini $home/.config/wf-shell.ini
}

config_app() {
  # install rust
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  
  sudo pkg install chromium vim
  sudo pkg install droid-fonts-ttf x11-fonts/wqy

  # input method
  sudo pkg install fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt zh-fcitx5-rime zh-rime-essay
  cp /usr/local/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart/
  mkdir -p $home/.config/autostart

  echo "#input method" >> $home/.zshrc
  echo "export GTK_IM_MODULE=fcitx" >> $home/.zshrc
  echo "export QT_IM_MODULE=fcitx" >> $home/.zshrc
  echo "export XMODIFIERS=@im=fcitx" >> $home/.zshrc
}

config_pkg_source
install_system_env
config_desktop_common
config_desktop_wayfire
config_app