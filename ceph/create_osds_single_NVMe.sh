#!/bin/sh

#drives=(`lsscsi | grep SEA | awk '{ print $6 }' | cut -c 6-`)
server=(osd01 osd02 osd03 osd04 osd05 osd06)

aserver=($server)

#echo ${drives[@]}

discover_osds () {
for i in "${aserver[@]}"; do 
#determine what roots disk is on remote node in cluster
 #rootdisk=$(ssh -q $i mount | grep "on \/ " | awk {'print $1'} | sed 's/.....//;s/.$//g')
  #determine all disks available to remote node in cluster
  #alldisks=$(ssh -q $i sudo parted -l | grep "Disk \/" | awk {'print $2'} | sed 's/.....//;s/.$//g' | xargs)
  alldisks=$(ssh -q $i sudo lsscsi | grep SEA | awk '{ print $6 }' | cut -c 6- | xargs) 
  #expand all disks and strip roots disk and white space
  #osds=$(echo "$alldisks" | sed 's/'$rootdisk'//g;s/^[ \t]*//')
  osds=$(echo "$alldisks")

for d in $osds; do

nosds=$(echo $i:$d)
echo $nosds
done
done
}

aosds=(`discover_osds | xargs`)
# ceph-deploy prepare disks
for i in "${aosds[@]}"; do
    ceph-deploy --overwrite-conf osd prepare $i
done

# ceph-deploy activate disks
for i in "${aosds[@]}"; do
   #strip trailing white space from $i
   osd=$(echo "$i" | sed 's/\s*$//g')
   ceph-deploy osd activate "$osd"1
done

