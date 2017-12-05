#!/bin/bash

# cd /usr/lib/vmware/modules/source/
vmw_source=/usr/lib/vmware/modules/source
mod_dest=/lib/modules/$(uname -r)/kernel/drivers/misc
mod_name=(vmnet vmmon)
vmw_ver=$(/usr/bin/vmware-installer -l | grep workstation | awk '{ print $2 }' | awk -F"." '{print $1 "." $2"." $3}')
kern_ver=$(uname -r | cut -c 1-4)
os_ver=$(grep "^VERSION=" /etc/os-release | awk -F"=" '{print $2}' | sed s/\"//g )
os_pretty_name=$(grep "^PRETTY_NAME" /etc/os-release | awk -F"=" '{print $2}' | sed s/\"//g )
run_dir="$(/usr/bin/pwd)"

if [[ $vmw_ver == "14.0.0" ]]; then
    
    #  If TW then fix lib links
    #  This is NOT needed for Leap or SLES
    #  This is outdated as of the release of VMware Workstation 14.0.0
    #if [ "$os_pretty_name" == "openSUSE Tumbleweed" ] ; then
    #    kern_ver=$(uname -r | cut -c 1-4)
        #if [ $kern_ver == "4.12" ] ; then
            #cp -r /usr/lib/vmware-installer/2.1.0/lib/lib/libexpat.so.0 /usr/lib/vmware/lib
            #cd /usr/lib/vmware/lib/libz.so.1
            #mv  libz.so.1 libz.so.1.old
            #ln -s /usr/lib64/libz.so ./libz.so
            #ln -s libz.so libz.so.1
	    #cd -
        #fi
    #fi
    # perform cleanup for ALL 
    for i in "${!mod_name[@]}"; do
	# cleanup directory
	if [[ -d "$vmw_source/${mod_name[i]}-only" ]]; then
		rm -rf $vmw_source/"${mod_name[i]}"-only
	else
		echo "the directory doesn/'t exist"
	fi
	# cleanup old compiled modules
	if [[ -e "$vmw_source/${mod_name[i]}.o" ]]; then
		rm $vmw_source/"${mod_name[i]}".o
	else
		echo "the file ${mod_name[i]}.o doesn/'t exist"
	fi
    done

    # extract drivers for ALL
    for i in "${!mod_name[@]}"; do
	# extract driver
	if [[ -e "$vmw_source/${mod_name[i]}.tar" ]]; then
		tar -xvf $vmw_source/"${mod_name[i]}".tar -C $vmw_source
	else
		echo "the module archive ${mod_name[i]}.tar doesn/'t exist"
	fi
    done	
    
    # apply patch for Leap + SLES NOT TW
    # As of VMware Workstation 14.0.0 this has not been tested for Leap or SLES
    if [ "$os_pretty_name" != "openSUSE Tumbleweed" ] ; then
        patchfile="${run_dir}/vmware.patch.423+sles"
        if [[ "$kern_ver" == "4.4" ]]; then
            patch -p 1 -u -d "$vmw_source" -i "$patchfile"
        else
            echo "Not kernel 4.4, bypassing patch"
        fi
    else
        # This is for TW 4.14 kernel only
        patchfile="${run_dir}/vmware.patch.tw"
        if [ "$kern_ver" == "4.14" ] ; then
            patch -p 1 -u -d "$vmw_source" -i "$patchfile"
        fi
    fi

    # make modules for ALL
    for i in "${!mod_name[@]}"; do
	    # make module
        if [[ -d "$vmw_source/${mod_name[i]}-only" ]]; then
            make -C $vmw_source/"${mod_name[i]}"-only/
        else
            echo "the module source for ${mod_name[i]}-only doesn/'t exist"
        fi
    done

    # Copy drivers to right location
    cmod=(vmmon.o vmnet.o) # array for compiled modules
    dmod=(vmmon.ko vmnet.ko) # array for destination modules
    
    for i in "${!cmod[@]}"; do
        # Copy the vmmon driver to right location
        if [[ -e "$vmw_source/${cmod[i]}" ]]; then
            cp $vmw_source/"${cmod[i]}" "$mod_dest"/"${dmod[i]}"
        else
            echo "The compile failed for the ${cmod[i]} driver"
        fi
    done
    #Execute Depmod to recreate /etc/modules.d
    depmod -a
    systemctl daemon-reload
    systemctl restart vmware.service
 

# Main else if don't have vmware 12.5.7
else
	tmpfile=$(mktemp -t)
	vmwweb_ver_url=https://my.vmware.com/web/vmware/info/slug/desktop_end_user_computing/vmware_workstation_pro/12_0
	wget -O "$tmpfile" "$vmwweb_ver_url"
	vmw_ver_lat=$(cat $tmpfile | grep "VMware Workstation Pro" | grep midProductColumn | grep Linux | awk '{ print $5 }')
	vmw_ver_release=$(cat $tmpfile | grep -A25 "VMware Workstation Pro" | grep -A25 Linux | grep midDateColumn | sed -e '1,1d' | sed -e 's/.* .*".//g' -e 's/<...>*$//g')
	vmw_dl_url=$(cat $tmpfile | grep -A25 "VMware Workstation Pro" | grep -A25 Linux | grep "Downloads" | tr -d '"' | awk '{ print $2 }' | cut -c 6-)
	rm $tmpfile

	echo "Upgrade VMware Workstation to the lastest version $vmw_ver_lat released on $vmw_ver_release"
	echo "Download from here:"
	echo "https://my.vmware.com$vmw_dl_url"
fi	

exit
