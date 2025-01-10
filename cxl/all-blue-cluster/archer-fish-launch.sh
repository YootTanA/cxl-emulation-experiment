#!/bin/bash
sudo /opt/qemu-jic23/bin/qemu-system-x86_64 \
-name "archer-fish" \
-daemonize \
-hda archer-fish.qcow2 \
-smp 4 \
-m 3G,slots=3,maxmem=6G \
-net bridge,br=br0 \
-net nic,model=virtio,macaddr=02:68:b3:29:da:98 \
-machine type=q35,cxl=on \
-device pxb-cxl,id=cxl.0,bus=pcie.0,bus_nr=52 \
-device cxl-rp,id=rp0,bus=cxl.0,chassis=0,port=0,slot=0 \
-object memory-backend-file,id=mem0,mem-path=/tmp/mem0,size=3G,share=true \
-device cxl-type3,bus=rp0,volatile-memdev=mem0,id=cxl-mem0 \
-M cxl-fmw.0.targets.0=cxl.0,cxl-fmw.0.size=3G
