#!/bin/bash
#create_osds.sh
# This script will automate the creation of the OSDs on all servers specified 
# in the array below. It makes assumptions about the type of disks for
# the variables alldisks for the OSDs and alljdisks for the journals. These
# will need to be adjusted for your environment in order to properly scan
# for the right disks in the OSD nodes. The alldisks variable is split into two
# sets so that they can be split between two journaling disks. In this case
# there are total of 28 disks so it will split at 14 disks. 
#set -x
# variables
server=(osd01 osd02 osd03 osd04 osd05 osd06)

# function
# disk discovery function for all OSD nodes and journals
discover_osds () {
for i in "${server[@]}"; do 
  #determine all disks available to OSD nodes in cluster
  alldisks=( $(ssh -q "$i" sudo lsscsi | grep SEA | awk '{ print $6 }' | cut 
-c 6- | xargs) )
  #determine all journal disks available to OSD nodes in cluster
  alljdisks=( $(ssh -q "$i" sudo lsscsi | grep INTEL | awk '{ print $7 }' | 
xargs) )
  
 # First set of OSDs 0-13 
for d in  "${alldisks[@]:0:14}"; do
osdseta+="$i:$d:${alljdisks[0]} "
#echo $osdseta
#exit for d
done 

# Second set of OSDs 14-27
for c in "${alldisks[@]:14:14}"; do
osdsetb+="$i:$c:${alljdisks[1]} "
#echo $osdsetb
#exit for c
done  
#exit for i
done

osds=(${osdseta[@]} ${osdsetb[@]})
echo "${osds[@]}"
}

aosds=$(discover_osds)

#ceph-deploy create disks
#for i in "${aosds[@]}"; do
# create OSDs	
#    ceph-deploy --overwrite-conf osd create --dmcrypt $i:/dev/nvme0n1 #with encryption
#    ceph-deploy --overwrite-conf osd create $i:/dev/nvme0n1
#done

ceph-deploy --overwrite-conf osd create "$aosds"

