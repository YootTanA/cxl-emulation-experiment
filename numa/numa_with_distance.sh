#!/bin/bash

sudo /opt/qemu-jic23/bin/qemu-system-x86_64 \
-drive file=./share1.qcow2,format=qcow2,index=0,media=disk,id=hd \
-m 4G,slots=4,maxmem=8G \
-smp 4 \
-machine type=q35,cxl=on \
-daemonize \
-net nic \
-net user,hostfwd=tcp::2223-:22 \
-object memory-backend-ram,size=2G,id=m0 \
-object memory-backend-ram,size=1G,id=m1 \
-object memory-backend-ram,size=1G,id=m2 \
-numa node,nodeid=0,memdev=m0,cpus=0-1 \
-numa node,nodeid=1,memdev=m1,cpus=2-3 \
-numa node,nodeid=2,memdev=m2 \
-numa dist,src=0,dst=1,val=30 \
-numa dist,src=0,dst=2,val=15 \
-numa dist,src=1,dst=2,val=15 \
