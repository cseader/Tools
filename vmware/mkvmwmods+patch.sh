#!/bin/bash

# cd /usr/lib/vmware/modules/source/
vmw_source=/usr/lib/vmware/modules/source
mod_dest=/lib/modules/$(uname -r)/kernel/drivers/misc
mod_name=(vmnet vmmon)
kern_ver=$(uname -r | awk -F'.' '{print $1"."$2}')

# Uncomment ONLY one line below...auto/manual VMW version identification
vmw_ver=$(/usr/bin/vmware -v | awk '{ print $3 }')  # Automatically identify VMW version
# vmw_ver="12.5.2"  # Manually specify VMW version (on systems using different path ie: Fedora)

# Kernel version this patch intends to address
target_kern_ver="4.10"

if [[ $vmw_ver == "12.5.2" ]]; then

# perform cleanup
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

# extract drivers and make modules

for i in "${!mod_name[@]}"; do
	# extract driver
	if [[ -e "$vmw_source/${mod_name[i]}.tar" ]]; then
		tar -xvf $vmw_source/"${mod_name[i]}".tar -C $vmw_source
	else
		echo "the module archive ${mod_name[i]}.tar doesn/'t exist"
	fi
done	

# apply patches
patchfile=$(/usr/bin/pwd)/vmware.patch
if [[ $kern_ver == $target_kern_ver ]]; then
    patch -p 1 -u -d "$vmw_source" -i "$patchfile"
else
    echo "Bypassing patch: Kernel version doesn't match patch's specified target."
fi

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
