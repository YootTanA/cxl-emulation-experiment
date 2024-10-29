## TLDR;

**To run the script in this repository, you are going to need to a few essential things.**

**First** is qemu-system-x86_64 binary that have CXL feature. So, go ahead to https://gitlab.com/jic23/qemu and build it.

**Second** you need a image with proper kernel config. For me I picked the image from this article https://memverge.com/cxl-qemuemulating-cxl-shared-memory-devices-in-qemu/

Once they're all set, you should get the output from `ls` that looks similar to this one

    user@host/cxl-emulation-experiment/numa:$ ls
    Fedora-Cloud-Base-38-1.6.x86_64.qcow2 numa.sh  numa_with_diff_distance.sh  share1.qcow2  share2.qcow2

Now go execute your preferred script and enjoy.

---



## To reproduce my experiment, please follow the steps below.

### Operating System
For a experiment, I always pick [Debian12](https://www.debian.org/releases/bookworm/debian-installer/ "Debian12") to install on my local machine since it's extremely easy to install.

If you prefer a different distribution, you will need to find necessary software dependencies and may skip the Dependencies section below.

### Dependencies

       sudo apt-get install libaio-dev liburing-dev libnfs-dev \
       libseccomp-dev libcap-ng-dev libxkbcommon-dev libslirp-dev \ 
       libpmem-dev python3.10-venv numactl libvirt-dev 

**Discliamer**: I have copied the dependencies above from https://memverge.com/cxl-qemuemulating-cxl-shared-memory-devices-in-qemu/ but I have not tested them since I have already set up all dependencies before discovering this resource. I will remove this message once I am certain it works.

### Install QEMU with CXL emulation
At this time the official QEMU are not supporting CXL emulation. Howevers, there are checkpoint branchs of QEMU project that allow us to emulate CXL abilities (Thanks to Johnathan Cameron).

This means you will need to manually build a QEMU binary from the git repository.

First, go clone the repository.

    git clone https://gitlab.com/jic23/qemu.git && cd qemu

Now, check out to the branch.

    git checkout cxl-2023-05-25

Then,

    mkdir build
    cd build
    ../configure --prefix=/opt/qemu-jic23 --target-list=i386-softmmu,x86_64-softmmu --enable-libpmem --enable-slirp

Before you go build the binary, let's discuss about `make` first.

To avoid wasting your time on build process, it is important to understand how the `make -j` work.

In short, you can specific the number of CPU cores to be used by adding a number after `-j`, like this `make -j8`, which allocates 8 CPU cores to the build process. (**With great power comes with great responsibility**)

Use `nproc` to determine your machine's CPU cores.

These are good resources for Parallel Execution with `make`
- https://www.gnu.org/software/make/manual/html_node/Parallel.html
- https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage

I assume that you have read the information above and ready to build the binary.

    make -j all
    sudo make install

Let's verify the binary.

    /opt/qemu-jic23/bin/qemu-system-x86_64 --version


The output should look similar to this:

	QEMU emulator version 7.2.50 (v6.2.0-8711-gbeb0973a68)

Now, it depends on you to move it to your /usr/bin or just let it here. 
For me, I'm okay to just let it here since I don't want a alpha version on my /usr/bin

### Download CXL-Enabled Image
Building my own personal QEMU image with CXL-Enabled Kernel config is beyond my knowledge for now.

Thus, we are going to trust and use a pre-build image from https://memverge.com/cxl-qemuemulating-cxl-shared-memory-devices-in-qemu/.

First, go download the image by `wget`

    wget -O memshare.tgz https://app.box.com/shared/static/7iu9dok7me6zk29ed263uhpkd0tn4uqt.tgz
	tar -xzf ./memshare.tgz

Now, we should have a directory named memshare in our current working space.

    $ ls memshare
    Fedora-Cloud-Base-38-1.6.x86_64.qcow2  launch.sh     share1.sh     share2.sh
    README.md                              share1.qcow2  share2.qcow2


Next, clone my repository to your local machine.

    git clone https://github.com/YootTanA/cxl-emulation-experiment.git


That's it for this section.

### Simulate a CXL device with NUMA
In this section we are going to use a script in `numa` directory to create a virtual machine that use a cpu-less NUMA node as a CXL device.

Before we begin we need to copy important files to `numa` directory

     cp ./memshare/{Fedora-Cloud-Base-38-1.6.x86_64.qcow2,share1.qcow2,share2.qcow2} ./cxl-emulation-experiment/numa/

When list files in `numa` directory, you should see something similar to the output below.

	$ ls cxl-emulation-experiment/numa/
	Fedora-Cloud-Base-38-1.6.x86_64.qcow2  numa_with_distance.sh  share2.qcow2  numa.sh                                share1.qcow2

Let's go check out `numa` directory

	cd cxl-emulation-experiment/numa

Since we now have all necessary resources to run a virtual machine with CXL on our server, let's first go over the content of my script.


Executing `numa.sh` script will give you a virtual machine that has three NUMA nodes. Node ID 2 is used as a CXL device since there are only memory on the device. It creates its initial drive from `share2.qcow2`.

NUMA nodes created by the script do not have any  distance configured between them.

    $ cat numa.sh 
    
	#!/bin/bash
    
    sudo /opt/qemu-jic23/bin/qemu-system-x86_64 \
    -drive file=./share2.qcow2,format=qcow2,index=0,media=disk,id=hd \
    -m 4G,slots=4,maxmem=8G \
    -smp 4 \
    -machine type=q35,cxl=on \
    -daemonize \
    -net nic \
    -net user,hostfwd=tcp::2222-:22 \
    -object memory-backend-ram,size=2G,id=m0 \
    -object memory-backend-ram,size=1G,id=m1 \
    -object memory-backend-ram,size=1G,id=m2 \
    -numa node,nodeid=0,memdev=m0,cpus=0-1 \
    -numa node,nodeid=1,memdev=m1,cpus=2-3 \
    -numa node,nodeid=2,memdev=m2 \


Run the script 

	chmod +x numa.sh
	./numa.sh

Once the virtual machine is running, you can secure shell into it.

	ssh fedora@localhost -p 2222

the **password** is `password`

When you already logged in, you can try the command below.

	 numactl --hardware

You should see the information of NUMA nodes.

Now, you can repeat the exat same steps with `numa_with_distance.sh` to create NUMA nodes with specific distances.
