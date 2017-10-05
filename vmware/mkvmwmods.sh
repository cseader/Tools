#!/bin/bash

# cd /usr/lib/vmware/modules/source/
vmw_source=/usr/lib/vmware/modules/source
mod_dest=/lib/modules/`uname -r`/kernel/drivers/misc
mod_name=(vmmon vmnet)

# perform cleanup
for i in "${!mod_name[@]}"; do
	# cleanup directory
	if [[ -d "$vmw_source/${mod_name[i]}-only" ]]; then
		rm -rf $vmw_source/${mod_name[i]}-only
	else
		echo "the directory doesn/'t exist"
	fi
	# cleanup old compiled modules
	if [[ -e "$vmw_source/${mod_name[i]}.o" ]]; then
		rm $vmw_source/${mod_name[i]}.o
	else
		echo "the file ${mod_name[i]}.o doesn/'t exist"
	fi
done

# extract drivers and make modules

for i in "${!mod_name[@]}"; do
	# extract driver
	if [[ -e "$vmw_source/${mod_name[i]}.tar" ]]; then
		tar -xvf $vmw_source/${mod_name[i]}.tar -C $vmw_source
	else
		echo "the module archive ${mod_name[i]}.tar doesn/'t exist"
	fi
	# make module
	if [[ -d "$vmw_source/${mod_name[i]}-only" ]]; then
		make -C $vmw_source/${mod_name[i]}-only/
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
		cp $vmw_source/${cmod[i]} $mod_dest/${dmod[i]}
	else
		echo "The compile failed for the ${cmod[i]} driver"
	fi
done

#Execute Depmod to recreate /etc/modules.d
depmod -a

exit
