#!/bin/bash
sudo qemu-system-x86_64 \
-name "orcar" \
-vnc :0 \
--enable-kvm \
-daemonize \
-hda orcar.qcow2 \
-smp 2 \
-m 3G,slots=3,maxmem=6G \
-net bridge,br=br0 \
-net nic,model=virtio,macaddr=52:55:00:00:da:98 \
