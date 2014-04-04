#!/bin/bash
# prepare-oracle-java-blackboard.sh
# author: Cameron Seader cs@suse.com
#
# This script will prepare your system for using Blackboard Collaborate with Sun Java
#

#Variables
tmpdir=`mktemp -d -t tmp.XXXXXX`
javaloc="/opt/java/64"
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

# Download the latest Sun Java 1.7
mkdir -p $tmpdir
if [ -d "$tmpdir" ]; then
wget -O /$tmpdir/jre-7u51-linux-x64.tar.gz http://javadl.sun.com/webapps/download/AutoDL?BundleId=83376
fi

if [ -e "$tmpdir/jre-7u51-linux-x64.tar.gz" ]; then
mkdir -p $javaloc
tar xzvf $tmpdir/jre-7u51-linux-x64.tar.gz -C /opt/java/64
fi

if [ -d "$tmpdir" ]; then
rm -rf $tmpdir
fi

if [ -d "$javaloc/jre1.7.0_51" ]; then
echo "Setting up Library Path"
echo "/opt/java/64/jre1.7.0_51/lib/amd64/" >> /etc/ld.so.conf.d/blackboard.conf

ldconfig 
fi

exit 0
