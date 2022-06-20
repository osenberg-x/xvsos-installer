###
 # @Copyright: xvsos
 # @Author: xvs
 # @Date: 2022-06-20 09:25:51
 # @LastEditTime: 2022-06-20 10:28:26
 # @LastEditors: OsenbergQu
 # @FilePath: \xvsos-installer\install.sh
 # @Description: 
### 
#! /bin/sh

user=xs
home=/home/$user

function config_pkg_source {
  dir="/usr/local/etc/pkg/repos"
  mkdir -p  $dir
  echo "FreeBSD: {" >> $dir/FreeBSD.conf
  echo "  url: \"pkg+http://mirrors.ustc.edu.cn/freebsd-pkg/${ABI}/latest\"" >> $dir/FreeBSD.conf
  # echo "  url: \"pkg+http://mirrors.ustc.edu.cn/freebsd-pkg/${ABI}/quarterly\""
  echo "}" >> $dir/FreeBSD.conf

  pkg update -f

  # update ports
  portsnap fetch
  portsnap extract
  portsnap fetch update
}

function config_ports_source {
  echo "MASTER_SITE_OVERRIDE?=http://mirrors.ustc.edu.cn/freebsd-ports/distfiles/\${DIST_SUBDIR}/" >> /etc/make.conf
}

function install_system_env {
  # install pkg
  cd /usr/ports/ports-mgmt/pkg; make; make install clean
  # sudo
  pkg install sudo
  echo "$user ALL=(ALL) ALL" >> /usr/local/etc/sudoers

  # zsh, oh-my-zsh
  pkg install zsh
  chsh -s /usr/local/bin/zsh
}

function config_desktop_sway {
  pw groupmod video -m $xs
  pkg install wayland seatd dbus drm-fbsd13-kms
  sysrc seatd_enable=”YES”

  mkdir -p $home/.config/runtime
  export XDG_RUNTIME_DIR=$home/.config/runtime

  git clone https://gitee.com/mirrors/oh-my-zsh.git $home/.oh-my-zsh
  cp ./zshrc.zsh-template $home/.zshrc

  sudo pkg install sway swayidle swaylock-effects alacritty wofi
  mkdir $home/.config/sway
  #cp /usr/local/etc/sway/config $home/.config/sway
  cp ./sway/config $home/.config/sway
}