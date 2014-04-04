#!/bin/bash
#prepare-openjdk-blackboard.sh
#Author: Cameron Seader cs@suse.com
#
# This script will prepare your system to use Blackboard Collaborate with OpenJDK Java
#

#Variables
javaloc="/usr/lib64/jvm/java-1.7.0-openjdk/jre/lib/amd64"
susever=`cat /etc/SuSE-release | grep VERSION | awk '{print $3}'`

case $susever in
# This will capture both SLED and SLES
11)
echo "Checking required packages are installed"

zypper -n in -y xorg-x11-libs-32bit xorg-x11-libs xorg-x11-libXmu xorg-x11-libXmu-32bit xorg-x11-libX11 xorg-x11-libX11-32bit glibc glibc-32bit xorg-x11-libXext xorg-x11-libXext-32bit xorg-x11-libXt xorg-x11-libXt-32bit xorg-x11-libxcb xorg-x11-libxcb-32bit xorg-x11-libSM xorg-x11-libSM-32bit xorg-x11-libICE xorg-x11-libICE-32bit xorg-x11-libXau xorg-x11-libXau-32bit libuuid1 libuuid1-32bit 

;;
# This will capture the most recent version of openSUSE
13.1)
echo "Checking required packages are installed"

zypper -n in -y libXtst6 libXmu6 libX11-6 glibc libXext6 libXt6 libxcb1 libSM6 libICE6 libXau6 libuuid1 

;;
esac

if [ -d "/etc/ld.so.conf.d" ]; then
echo "Setting up Library Path"
echo "$javaloc" >> /etc/ld.so.conf.d/blackboard.conf

ldconfig
fi

exit 0
