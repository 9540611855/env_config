#!/bin/bash
#更新国内源针对的是ubuntu18.04

#源文件夹路径

version=""
#检查是否为root权限运行此脚本

function isroot () {
  if [ $(id -u) -ne 0 ]; then
    echo "[!]This script must be run as root"
    exit 1  
  fi
}

#保存source文件
function backup_source(){
    echo -e "[*]backup sources.list -> sources.list.back"
    mv /etc/apt/sources.list /etc/apt/sources.list.$(date +%F-%R)
}

#设置系统的版本
function set_system_version(){
  if [ -z "$1" ]
  then
  echo "[!]First argument is empty(version)"
  echo "[!]default version->bionic"
  version="bionic"
  else
  version=$1
  fi
}
function update_sources() {
    echo -e "[*]start update sources"
    local COMP="main restricted universe multiverse"
    local source_path="/etc/apt/sources.list"
    touch $source_path
    local mirror="http://mirrors.aliyun.com/ubuntu/"
    echo "deb  $mirror $version $COMP" >>$source_path
    echo "deb  $mirror $version-updates $COMP" >>$source_path
    echo "deb  $mirror $version-backports $COMP" >>$source_path
    echo "deb  $mirror $version-security $COMP" >>$source_path
    echo "deb  $mirror $version-proposed $COMP" >>$source_path
    echo "deb-src  $mirror $version $COMP" >>$source_path
    echo "deb-src  $mirror $version-updates $COMP" >>$source_path
    echo "deb-src  $mirror $version-backports $COMP" >>$source_path
    echo "deb-src  $mirror $version-security $COMP" >>$source_path
    echo "deb-src  $mirror $version-proposed $COMP" >>$source_path
    echo -e "[*]Your sources has been updated,  run "sudo apt-get update" now."
    sudo apt-get update -y > /dev/null 2>&1 &
    wait $!

}


function install_git_curl () {
  echo -e "[*]start install git curl"
  sudo apt-get install -y git  2>&1 &
  wait $!
  sudo  apt-get install -y curl   2>&1 &
  wait $!
  if ! command -v git &> /dev/null; then
    echo "git installation failed"
    exit 1
  fi
  if ! command -v curl &> /dev/null; then
    echo "curl installation failed"
    exit 1
  fi
}


function update_pip_source(){
  echo -e "[*]start update pip sources"
  if [ ! -e "~/.pip" ]
    then
    mkdir ~/.pip
  fi
  touch ~/.pip/pip.conf
  echo "[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
" >> ~/.pip/pip.conf
}


function install_zsh () {
  echo -e "[*]start install zsh"
# Install zsh
  sudo apt-get update -y > /dev/null 2>&1 &
  wait $!
  
  sudo apt-get install -y zsh 2>&1 &
  wait $!

# Install Oh My Zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install plugins
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-completions.git ~/.oh-my-zsh/custom/plugins/zsh-completions
  git clone https://github.com/zsh-users/zsh-history-substring-search.git ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search

# Set zsh as default shell
  sudo chsh -s $(which zsh)

# Update .zshrc file with plugins
  sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions zsh-completions zsh-history-substring-search)/g' ~/.zshrc

# Reload .zshrc file
  source ~/.zshrc
}
function install_peda () {
  echo -e "[*]start install peda"
# Install PEDA GDB plugin
  git clone https://github.com/longld/peda.git ~/peda
  echo "source ~/peda/peda.py" >> ~/.gdbinit

  # Reload .gdbinit file
  source ~/.gdbinit
}

main()  
{ 

  echo -e "[*]start run updateSource.sh"
  isroot
  set_system_version $1
  backup_source
  update_sources
  update_pip_source
  install_git_curl
  install_zsh
  install_peda
  echo -e "[*]all done"
}
main $1