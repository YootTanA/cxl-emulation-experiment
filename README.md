## CXL Emulation on a Debian Virtual Machine

This repository contains my journey on how to emulate a CXL device on a Debian
virtual machine. 

**NOTE:** If you'd like to create a new virtual machine with a different Linux distribution,
this guide maybe helpful; however you have to figure out how to solve the problems that could happen
along the way by yourself.

##

### Table of contents
- [What is a CXL device?](https://github.com/YootTanA/cxl-emulation-experiment#what-is-a-cxl-device)
- [Why do I need a emulating CXL device?](https://github.com/YootTanA/cxl-emulation-experiment#why-do-i-need-a-emulating-cxl-device)
- [Create a virtual machine image](https://github.com/YootTanA/cxl-emulation-experiment#create-a-virtual-machine-image)
- [Configure the virtual machine's kernel]()

##


### What is a CXL device?
Well, this might be the first question that come to mind, if you've never heard of this device before.
As for me, I'm still exploring the posibility of this kind of device. 

Since this article tend to focus on how to create a customized kernel machine for CXL emulation so do yourself a favor by reading these resources below:

- https://www.rambus.com/blogs/compute-express-link/ 
- https://www.trentonsystems.com/en-us/resource-hub/blog/what-is-compute-express-link-cxl
- https://computeexpresslink.org/about-cxl/
- https://computeexpresslink.org/wp-content/uploads/2024/03/CXL_An-Introduction-to-CXL-Technology-Webinar.pdf

##


### Why do I need a emulating CXL device?

Simple answer is I just need to study and experiment on such a device. **But, how can I get one of the device?!!** 

This kind of device is rare to find on the market and the price are quite expensive.

Checking the price:
- https://memverge.com/cxl-use-case-slash-memory-costs-and-expand-capacity/

For the reason, I need to find the way to emulate the characteristic of this device in my experiment.

#### The Exist CXL Emulation

Luckily, I've come across these articles from memverge below which is the starting point of this repository.

- https://memverge.com/emulating-cxl-memory-expanders-in-qemu/
- https://memverge.com/cxl-qemuemulating-cxl-shared-memory-devices-in-qemu/

In the articles, they created a virtual machine image with customized kernel using a software called [QEMU](https://www.qemu.org/) and emulated a CXL device on it. Apart from sharing their QEMU image, they also provide steps by steps walkthrough for emulating such a device on a virtual machine.

#### Problems With The QEMU Image From Memverge Articles In My Experiment

In my experiment setup, I need my host machine to has at least one CXL device functioning as memory expander and I also need to deploy a serverless platform on the machine (I chose [Knative](https://knative.dev/docs/)). However, when I tried to install Knative on the machine, I encounterd error messages, some of which indicated that a kernel was panic caused by the installtion.

My theory is that they configured the kernel to be small, prestine, and focused soely on CXL emulation. 

To address this problem, the first idea that came to my mind was to create a customized kernel QEMU image myself. This is why you have found this document here.

##

### Create a virtual machine image

First things first, we'll need a virtual machine image that is ready to boot a operating system up. Of course, I went for my comfort operating system which is Debian 12. 

**Important NOTE:** I'm using Debian 12 as a operating system for my host machine. I personally recommend installing a Desktop Environment on your server and using it throughout this walkthrough, as this can help to avoid potential `gtk initialization` issues, which may otherwise take a significant amount of time to resolve. 

#### Create a QEMU Debian 12 image


Install necessary dependencies on the host operating system

```bash
apt install qemu-utils qemu-system-x86 qemu-system-gui
```

Create a working directory (optional)

```bash
mdkir debian12-qemu && cd debian12-qemu
```

Download a Debian 12 image

```bash
wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.8.0-amd64-netinst.iso
```

Create the hard disk image

**NOTE:** Before running the command below, it's worth to understand the difference between raw and qcow2 formats. I recommend reading more about them from the reliable sources. 

In short, the reason I chose qcow2 format is that it stands for **QEMU Copy-On-Write version 2**. As that name suggests, qcow2 natively works with QEMU software and supports features likes snapshots and compression, which allow it to use less disk space compare to raw format.

**disclaimer** I've never tried using raw format in my experiment before. If I get a change to try it, I will come back to update the result.

```bash
qemu-img create -f qcow2 debian.qcow2 20G
```

Boot the image and install Debian 12 minimal server on it

**NOTE** I have 16 gigabyte of memory on my server, so I allocated half of it to the booting process. You may want to adjust the memory allocation to suit the constraints of your physical machine. The same applies to adjusting the number of CPU cores.

- **change the number behind -m flag to adjust memory allocation**
- **change the number behind -smp flag to adjust CPU cores**

Modifying these numbers will significantly improve the booting process. 

```bash
qemu-system-x86_64 -hda debian.qcow2 -cdrom debian-12.8.0-amd64-netinst.iso -boot d -m 8G -smp 10
```

After booting and installtion are done, we are now ready to the next step.

##

### Configure the virtual machine's kernel

Before proceeding this step, you need to finished the earlier step ([Create a virtual machine image](https://github.com/YootTanA/cxl-emulation-experiment#create-a-virtual-machine-image)) 

In this step, we will use the `debian.qcow2` image that we just creaetd to boot up the virtual image, and then we will customize its kernel to enable kernel functionlity for working with CXL devices.

#### Booting up a virtual machine from the image

**NOTE:** Some of commands below might require permission to run. I don't want to judge your journey by adding
**sudo** in front of the command, as I know there are some nerds prefer using **doas** or others root management tools.

Launching the virtual machine with the following command

```bash
qemu-system-x86_64 \
-hda debian.qcow2 \
-smp 10 \
-m 8G \
-net user,hostfwd=tcp::2222-:22 \
-net nic \
```

Once the virtual machine successfully start up, we can begin building a new kernel for CXL devices.

#### Configure a new kernel

In the virtual machine, go download a kernel source to the local working directory.

```bash
wget https://mirrors.edge.kernel.org/pub/linux/kernel/v6.x/linux-6.3.7.tar.xz
```

I specifically went for the kernel version 6.3.7, as it is the same version as the one in the image from Memverge.

Uncompress the tar file

```bash
tar xaf linux-6.3.7.tar.xz && cd linux-6.3.7
```

Copy the old kernel config to the directory (In Debian, it resides in /boot)

```bash
cp /boot/config-6.1.0-26-amd64 .config
```

Now we are ready to rock, run the command below to configure kernel config.
If this is your first time, I bet your are feeling excited right now.

```bash
make menuconfig
```

The grey screen full of configurations should appear on your terminal. If it don't, you might did something wrong.


Kernel configurations below are the ones I applied to my virturl machine.
The article from Memverge states that `CONFIG_CXL_REGION_INVALIDATION_TEST` is the required configuration.
Anyway, it's not hurt to follow my configuration that is already work on my virtual machine.

```bash
CONFIG_CXL_BUS=y
CONFIG_CXL_PCI=m
CONFIG_CXL_ACPI=m
CONFIG_CXL_PMEM=m
CONFIG_CXL_MEM=m
CONFIG_CXL_PORT=y
CONFIG_CXL_SUSPEND=y
CONFIG_CXL_REGION=y
CONFIG_CXL_REGION_INVALIDATION_TEST=y
CONFIG_DEV_DAX_CXL=m
```

Once you have finished and saved the new configuration, you will need to compile a new kernel.

But hold your hourses!! Before we are going further, I want to give you some insight.

Compiling kernel could be a super long process, sometimes it takes day to finishes depend on your hardwares. Moreover, it is a memory consuming process, it will allocate a lot of memory for display debugging output. 

Run the below command to create a environment variable that will disable the output.

```bash
export DEB_BUILD_PROFILES='pkg.linux.nokerneldbg pkg.linux.nokerneldbginfo'
```

Then verify if the new variable is loaded

```bash
printenv | grep DEB_BUILD_PROFILES
```

Trust me, you don't want to let your kernel compile overnight, only to wake up and find it has failed. (I learned it hard way though)

**Reference**
- https://kernel-team.pages.debian.net/kernel-handbook/ch-common-tasks.html#s-common-building

From now on, we will be compiling the kernel. I used `-j10` in the command below since my virtual machine has 10 CPU cores.
If you would like to accelerate you build process, don't forget to add the flag to the command and adjust to what suit your hardwares.

```bash
sudo make -j10 bindeb-pkg
```

It will take a long time. Let go grab a glass of coffee or yellow liquid (you know what I mean?) 

Once, the compiling has done. Run this command to verify that we have the package for install a new kernel.

```bash
ls ../ | grep *.deb
```

You should see some `*.deb` files, unless there is something wrong.

Let's say that everything is okay. Go to where *.deb files reside and run this command.

```bash
sudo dpkg -i linux-*.deb
```

Now, the kernel will be installed and Grub also be updated as a new kernel has emerged on your virtual machine.

Let's reboot, and see if the kernel has changed to 6.3.7 or not.

