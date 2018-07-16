==================
	  KaT OS
==================

KaT OS is simple OS written in modern C++.

Every single step from building cross compiler to documentation is automated, only prerequisites are virtualbox and vagrant.

::

    git clone git@github.com:frainfreeze/scratchpad.git
    cd scratchpad && vagrant up

The bootstrap.sh script will get executed on machines boot and install all the tools you need to compile the OS.
It will also run makefiles and output OS image in /home/build.



.. Note::

	To log into virtual machine run `vagrant ssh`, to exit the VM run `logout`, to shutdown the machine run `vagrant halt`, and finally to terminate use of resources on your machine (including virtual machines disks) run `vagrant destroy`.
