#!/bin/bash

for osd in {4,11,18}; do
	ceph osd crush reweight osd.$osd 0
done

for osd in {4,11,18}; do 
	ceph osd out $osd
done

for osd in {4,11,18}; do
	ceph osd crush remove osd.$osd
	ceph auth del osd.$osd
done

