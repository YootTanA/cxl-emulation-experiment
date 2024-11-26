## CXL Emulation on a Debian Virtual Machine

This repository contains my journey on how to emulate a CXL device on a Debian
virtual machine. 

**NOTE:** If you'd like to create a new virtual machine with a different Linux distribution,
this guide maybe helpful; however you have to figure out how to solve the problems that could happen
along the way by yourself.

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

