#!/bin/bash    

set -x
SIRFUSERNAME=sirfuser
SIRFPASS=virtual

# check if user exists. if not create it. Useful for vagrant provision
id -u $SIRFUSERNAME
if [ $? -eq "1" ] ; then
  adduser $SIRFUSERNAME
  adduser $SIRFUSERNAME sudo
  { echo $SIRFPASS; echo $SIRFPASS; } | passwd $SIRFUSERNAME 
fi

# fail hard on any step
set -ex
# update the apt-get database
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get upgrade -y -o Dpkg::Options::=--force-confnew
# upgrade the list of packages


#install upgrades
apt-get update && apt-get install -y --no-install-recommends wget git xorg xterm gdm3 menu policykit-1-gnome synaptic gnome-session gnome-panel metacity
apt-get update && apt-get install -y at-spi2-core gnome-terminal gnome-control-center nautilus dmz-cursor-theme network-manager network-manager-gnome

# start gnome display manager
service gdm start

# set the current locale, otherwise the gnome-terminal doesn't start
sudo locale-gen en_GB.UTF-8
sudo locale-gen en_US.UTF-8
sudo locale-gen de_DE.UTF-8
sudo locale-gen fr_FR.UTF-8
sudo locale-gen es_ES.UTF-8
sudo locale-gen it_IT.UTF-8
sudo locale-gen pt_PT.UTF-8
sudo locale-gen pt_BR.UTF-8
sudo locale-gen ja_JP.UTF-8
sudo locale-gen zh_CN.UTF-8
sudo update-locale LANG=en_GB.UTF-8
sudo localectl set-x11-keymap uk
sudo localectl status


# To hide vagrant from login screen:
#  1. Log-in as vagrant
#  2. In /var/lib/AccountsService/users/vagrant change 'SystemAccount=true'
sudo echo '[User]' > vagrant
sudo echo 'SystemAccount=true' >> vagrant
sudo cp -v vagrant /var/lib/AccountsService/users/vagrant

  # To remove the Ubuntu user from VM:
#sudo deluser --remove-home ubuntu
# Could add custom logos here: /etc/gdm3/greeter.dconf-defaults 

userHOME=/home/$SIRFUSERNAME

if [ ! -d $userHOME/devel ]; then
  mkdir $userHOME/devel 
fi
cd $userHOME/devel

if [ ! -d $userHOME/devel/CCPPETMR_VM ]; then
  git clone https://github.com/CCPPETMR/CCPPETMR_VM.git
  cd CCPPETMR_VM
  git checkout ubuntu18.04
else
  cd CCPPETMR_VM
  git checkout ubuntu18.04
  git pull
fi



bash $userHOME/devel/CCPPETMR_VM/scripts/INSTALL_prerequisites_with_apt-get.sh
bash $userHOME/devel/CCPPETMR_VM/scripts/INSTALL_CMake.sh /usr/local
bash $userHOME/devel/CCPPETMR_VM/scripts/INSTALL_python_packages.sh

# port 8888 is forwarded to 8888 so the user can use the host browser
# Therefore no browser is installed on the VM
#python -m pip install jupyter
#python -m pip install spyder

chown -R $SIRFUSERNAME:users $userHOME
# the ubuntu18.04 branch latest commit
sudo -u $SIRFUSERNAME -H bash $userHOME/devel/CCPPETMR_VM/scripts/UPDATE.sh -t origin/add_cil
