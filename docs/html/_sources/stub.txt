
Installing virtualbox and vagrant on Debian 9
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

    # add stretch-backports main and contrib to your apt sources
    sudo apt install virtualbox
    wget https://releases.hashicorp.com/vagrant/2.1.1/vagrant_2.1.1_x86_64.deb
    sudo dpkg -i vagrant_2.1.1_x86_64.deb


Building ISO 
~~~~~~~~~~~~
We will create the kernel ISO image with the program genisoimage. A folder must first be created that contains the files that will be on the ISO image. The following commands create the folder and copy the files to their correct places:

.. code::

    mkdir -p iso/boot/grub              # create the folder structure
    cp stage2_eltorito iso/boot/grub/   # copy the bootloader
    cp kernel.elf iso/boot/             # copy the kernel


A configuration file menu.lst for GRUB must be created. This file tells GRUB where the kernel is located and configures some options:

.. code::

    default=0
    timeout=0

    title os
    kernel /boot/kernel.elf

Place the file menu.lst in the folder iso/boot/grub/. The contents of the iso folder should now look like the following figure:

.. code::

    iso
    |-- boot
      |-- grub
      | |-- menu.lst
      | |-- stage2_eltorito
      |-- kernel.elf

The ISO image can then be generated with the following command:

.. code::

    genisoimage -R                              \
                -b boot/grub/stage2_eltorito    \
                -no-emul-boot                   \
                -boot-load-size 4               \
                -A os                           \
                -input-charset utf8             \
                -quiet                          \
                -boot-info-table                \
                -o os.iso                       \
                iso

For more information about the flags used in the command, see the manual for genisoimage.

The ISO image os.iso now contains the kernel executable, the GRUB bootloader and the configuration file.