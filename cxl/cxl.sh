#!/bin/bash

sudo /opt/qemu-jic23/bin/qemu-system-x86_64 \
-machine q35,accel=kvm,nvdimm=on,cxl=on \
-drive file=./share2.qcow2,format=qcow2,index=0,media=disk,id=hd \
-device e1000,netdev=net0,mac=52:54:00:12:34:56 \
-daemonize \
-netdev user,id=net0,hostfwd=tcp::2224-:22 \
-m 2G,slots=8,maxmem=6G \
-smp cpus=4,cores=2,sockets=2 \
-object memory-backend-ram,size=1G,id=mem0 \
-numa node,nodeid=0,cpus=0-1,memdev=mem0 \
-object memory-backend-ram,size=1G,id=mem1 \
-numa node,nodeid=1,cpus=2-3,memdev=mem1 \
-object memory-backend-ram,id=cxl-mem0,share=on,size=256M \
-device pxb-cxl,numa_node=0,bus_nr=16,bus=pcie.0,id=cxl.0 \
-device cxl-rp,port=0,bus=cxl.0,id=root_port16,chassis=0,slot=0 \
-device cxl-type3,bus=root_port16,volatile-memdev=cxl-mem0,id=cxl-mem0 \
-object memory-backend-file,id=cxl-pmem1,share=on,mem-path=/tmp/cxltest1.raw,size=256M \
-object memory-backend-file,id=cxl-lsa1,share=on,mem-path=/tmp/lsa1.raw,size=256M \
-object memory-backend-ram,id=cxl-mem2,share=on,size=256M \
-object memory-backend-file,id=cxl-pmem2,share=on,mem-path=/tmp/cxltest2.raw,size=256M \
-object memory-backend-file,id=cxl-lsa2,share=on,mem-path=/tmp/lsa2.raw,size=256M \
-device pxb-cxl,numa_node=0,bus_nr=24,bus=pcie.0,id=cxl.1 \
-device cxl-rp,port=0,bus=cxl.1,id=root_port24,chassis=1,slot=0 \
-device cxl-upstream,bus=root_port24,id=sw0 \
-device cxl-downstream,port=1,bus=sw0,id=sw0port1,chassis=1,slot=1 \
-device cxl-type3,bus=sw0port1,persistent-memdev=cxl-pmem1,lsa=cxl-lsa1,id=cxl-pmem1 \
-device cxl-downstream,port=2,bus=sw0,id=sw0port2,chassis=1,slot=2 \
-device cxl-type3,bus=sw0port2,volatile-memdev=cxl-mem2,persistent-memdev=cxl-pmem2,lsa=cxl-lsa2,id=cxl-pmem2 \
-device pxb-cxl,numa_node=1,bus_nr=32,bus=pcie.0,id=cxl.2 \
-device cxl-rp,port=0,bus=cxl.2,id=root_port32,chassis=2,slot=0 \
-device cxl-upstream,bus=root_port32,id=sw1 \
-device cxl-downstream,port=0,bus=sw1,id=sw1port0,chassis=2,slot=1 \
-object memory-backend-ram,id=cxl-mem3,share=on,size=256M \
-device cxl-type3,bus=sw1port0,volatile-memdev=cxl-mem3,id=cxl-mem3 \
-device cxl-downstream,port=1,bus=sw1,id=sw1port1,chassis=2,slot=2 \
-object memory-backend-ram,id=cxl-mem4,share=on,size=256M \
-device cxl-type3,bus=sw1port1,volatile-memdev=cxl-mem4,id=cxl-mem4 \
-object memory-backend-file,id=cxl-pmem5,share=on,mem-path=/tmp/cxltest5.raw,size=256M \
-object memory-backend-file,id=cxl-lsa5,share=on,mem-path=/tmp/lsa5.raw,size=256M \
-device pxb-cxl,numa_node=1,bus_nr=40,bus=pcie.0,id=cxl.3 \
-device cxl-rp,port=0,bus=cxl.3,id=root_port40,chassis=3,slot=0 \
-device cxl-type3,bus=root_port40,persistent-memdev=cxl-pmem5,lsa=cxl-lsa5,id=cxl-pmem5 \
-M \
cxl-fmw.0.targets.0=cxl.0,cxl-fmw.0.size=4G,\
cxl-fmw.1.targets.0=cxl.1,cxl-fmw.1.size=4G,\
cxl-fmw.2.targets.0=cxl.2,cxl-fmw.2.size=4G,\
cxl-fmw.3.targets.0=cxl.3,cxl-fmw.3.size=4G

