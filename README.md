
**To run the script in this repository, you are going to need to a few essential things.**

**First** is qemu-system-x86_64 binary that have CXL feature. So, go ahead to https://gitlab.com/jic23/qemu and build it.

**Second** you need a image with proper kernel config. For me I picked the image from
this article https://memverge.com/emulating-cxl-memory-expanders-in-qemu/

Once they're all set, you should get the output from `ls` that looks similar to this one

    user@host/CXL_experiment/numa:$ ls
    Fedora-Cloud-Base-38-1.6.x86_64.qcow2 numa.sh  numa_with_diff_distance.sh  share1.qcow2  share2.qcow2

Now go execute your preferred script and enjoy.
