PXE automated deployment
------------------------

In this directory you can find 3 subdirectories containing my personal
example configuration for fast deploying centos in libvirt.

Here is a list and explanation of the subdirectories: 

 * *libvirt/:* the preliminary configuration for libvirt to make this system work
   at the core of this is the network configuration laid out here
 * *tftpboot/:* the files that should go into your tftp servers root to boot mainly
   binary files of centos and a boot command prompt plus messags etc.
 * *www/:* here the centos kickstart config and the post installation centos config
   tar file is placed. This will be pulled onto the new instance and manages the installation

