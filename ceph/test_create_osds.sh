#!/bin/bash
#set -x
#variables
server=(osd01 osd02 osd03 osd04 osd05 osd06)

# disk discovery function for all OSD nodes
discover_osds () {
for i in "${server[@]}"; do 
  #determine all disks available to OSD nodes in cluster
  alldisks=(sdc sdd sde sdf sdg sdh) 
  alljdisks=(/dev/sdb /dev/sda)
      
 #osds=$(echo "${alldisks[@]}")
 
for d in "${alldisks[@]:0:3}"; do
osdseta+="$i:$d:${alljdisks[0]} "
#echo $osdseta
done  

for c in "${alldisks[@]:3:3}"; do
osdsetb+="$i:$c:${alljdisks[1]} "
#echo $osdsetb
done  

done

osds=(${osdseta[@]} ${osdsetb[@]})
echo ${osds[@]}
}

discover_osds

#aosds=$(discover_osds | xargs)

 #determine all journal disks available to OSD nodes in cluster
#  alljdisks=(/dev/sdb /dev/sda)
#  jdisks=$(echo "${alljdisks[@]}")
  


#osdseta=$(echo "${aosds[@]:0:3}")
#osdsetb=$(echo "${aosds[@]:2:3}")

#for j in ${jdisks[0]}; do
 #for c in $osdseta; do
  #osda=$(echo $c:$j)	
  #echo $osda 
 #done
#done

#for j in ${jdisks[1]}; do
 #for c in $osdsetb; do
  #osda=$(echo $c:$j)	
  #echo $osdb 
 #done
#done

#ajournals=(`discover_journals | xargs`)

#echo $aosds

#ceph-deploy create disks
#for i in "${aosds[@]}"; do
# create OSDs	
#    ceph-deploy --overwrite-conf osd create --dmcrypt $i:/dev/nvme0n1 #with encryption
#    ceph-deploy --overwrite-conf osd create $i:/dev/nvme0n1
#done
