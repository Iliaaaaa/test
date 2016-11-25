#!/bin/bash
function auto {
    sudo rm /etc/init/autolaunch.conf
    sudo printf "respawn\nrespawn limit 15 5\n\nstart on runlevel [2345]\nstop on shutdown\n\nsetuid yourusername\nexec /bin/sh telegrambotpath/autolaunch.sh" >> /etc/init/autolaunch.conf
    sudo sed -i "s/yourusername/$(whoami)/g" /etc/init/autolaunch.conf
    sudo sed -i "s_telegrambotpath_$(pwd)_g" /etc/init/autolaunch.conf
}
clear
echo -e "			\e[0;36m _ _____\e[0m"
echo -e "			\e[1;37m(_)_   _|__  __ _ _ __ ___\e[0m"
echo -e "			\e[0;33m| | | |/ _ \/ _| | '_ _ _ \\"
echo -e "			\e[0;32m| | | |  __/ (_| | | | | | |\e[0m"
echo -e "			\e[0;35m|_| |_|\___|\__,_|_| |_| |_|\e[0m"
echo "________________________________________________________________________________"
echo -e "\e[0;36mInstalling Script\e[0m"
rm autolaunch.sh
wget http://iteam-co.ir/autolaunch.sh
chmod 777 autolaunch.sh
auto
sudo stop autolaunch
sudo start autolaunch
echo -e "\e[0;36mScript Installed\e[0m"
echo -e "\e[0;33mBot Is Running And Never Will Stop :)\e[0m"
echo -e "\e[0;35mEnjoy!\e[0m"
exit
