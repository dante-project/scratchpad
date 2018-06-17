Introduction
=======================

Developing OS is complex task that requires very specific development environment and set of tools. Theoretically one could write an OS in any language he wants, however assembly, C and C++ are de facto languages for this kind of job.

Our compiler suite of choice is GCC, build system cmake, and scripting language Bash. Everything is build and assembled inside virtual machine built by vagrant. Vagrant enables us to automate complete complex process of building cross compiler, os, linking and producing iso (even building documentation) into a single ``vagrant up`` command.

All development and examples were ran on Debian 9. Fell free to work from vagrant machine if you don't want to bother with setuping everything on your own host OS.

Basics
=======================
x86 is a family of backward-compatible instruction set architectures based on the Intel 8086 CPU and its Intel 8088 variant. The 8086 was introduced in 1978 as a fully 16-bit extension of Intel's 8-bit-based 8080 microprocessor, with memory segmentation as a solution for addressing more memory than can be covered by a plain 16-bit address. The term "x86" came into being because the names of several successors to Intel's 8086 processor end in "86", including the 80186, 80286, 80386 and 80486 processors. [1]


First steps
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Small assembly code to demonstrate building bootable iso image.

.. code-block:: gas

  .code16                ;tells GAS to output 16-bit code
  .global _start
  _start:
      cli                ;disable software interrupts
      mov $msg, %si
      mov $0x0e, %ah
  loop:
      lodsb
      or %al, %al
      jz halt
      int $0x10           ;BIOS call tp print the chars
      jmp loop
  halt:
      hlt                 ;halt the processor
  msg:
      .asciz "hello world"
  .org 510                ;magic bytes
  .word 0xaa55            ;magic bytes

To compile the assembler you can run following commands:

.. code-block:: bash

  as -o main.o main.S
  ld --oformat binary -o kernel.bin -Ttext 0x7C00 main.o

We have two important flags here:

1.  --oformat binary: output raw binary assembly code, don't warp it inside an ELF file as is the case for regular userland executables.

2. -Ttext 0x7C00: we need to tell the linker ld where the code will be placed so that it will be able to access the memory.

For this we would usually write a linker script. Now that we have the "kernel" we can build an iso.

If you have GRUB installed, you can check whether a file has a valid Multiboot version 1 header, 
which is the case for our kernel. It's important that the Multiboot header is within the first 
8 KiB of the actual program file at 4 byte alignment. This can potentially break later if you 
make a mistake in the boot assembly, the linker script, or anything else that might go wrong. 
If the header isn't valid, GRUB will give an error that it can't find a Multiboot header when 
you try to boot it. This code fragment will help you diagnose such cases: 

.. code:: bash

  grub-file --is-x86-multiboot

Grub-file is quiet but will exit 0 (successfully) if it is a valid multiboot kernel and exit 1
(unsuccessfully) otherwise. You can type ``echo $?`` in your shell immediately afterwards to see 
the exit status. 


Building ISO 
~~~~~~~~~~~~
We will create the kernel ISO image with the program genisoimage. A folder must first be created that contains the files that will be on the ISO image. The following commands create the folder and copy the files to their correct places:

.. code:: bash

    mkdir -p iso/boot/grub              # create the folder structure
    cp stage2_eltorito iso/boot/grub/   # copy the bootloader
    cp kernel.elf iso/boot/             # copy the kernel


A `configuration file <https://www.gnu.org/software/grub/manual/legacy/Configuration.html#Configuration>`_ menu.lst for GRUB must be created. This file tells GRUB where the kernel is located and configures some options:

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

Finally, make a ISO9660 image file like this: 

.. code:: bash

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
This produces a file named os.iso, which then can be burned into a CD (or a DVD) or loaded directly into virtual machine.
The ISO image contains the kernel executable, the GRUB bootloader and the configuration file.

To run the OS in qemu emulator executable

.. code:: bash

    qemu-system-i386 -cdrom os.iso 

Development environment
=======================
We will be building and installing a lot of tools rather frequently and many things can go wrong.
To make our life easier we can use virtual machines and to make everything even more hassle free,
we can utilize virtual machine manager, such as vagrant. 

Preparing the box
~~~~~~~~~~~~~~~~~~~
Installing virtualbox and vagrant on Debian 9 is rather straightforward:

.. code:: bash

    # add stretch-backports main and contrib to your apt sources
    sudo apt install virtualbox
    wget https://releases.hashicorp.com/vagrant/2.1.1/vagrant_2.1.1_x86_64.deb
    sudo dpkg -i vagrant_2.1.1_x86_64.deb

Once we have the software we can write small vagrant script:

.. code:: ruby

  # -*- mode: ruby -*-
  # vi: set ft=ruby :
  Vagrant.configure("2") do |config|
    config.vm.box = "generic/debian9"
    config.vm.box_check_update = false
    config.vm.synced_folder ".", "/home/src"
    config.vm.provision :shell, path: "bootstrap.sh"
  end

Save it as Vagrantfile in the root of the project. This particular vagrant file downloads
Debian 9 image, mounts its root directory under ``/home/src`` in the virtual machine and
executes ``bootstrap.sh``. Shell script then invokes ``i686-elf-tools.sh`` script that 
downloads necessary sources and compiles cross compiler. Once the compiler is built 
bootstrap script invokes cmake that builds the OS itself, builds bootable iso and 
documentation.

Finally, starting whole building process is as simple as executing ``vargant up`` in the 
projects root directory.

Cross Compiler
~~~~~~~~~~~~~~
.. image:: cross-compiler.png


1. https://en.wikipedia.org/wiki/X86
2. https://www.gnu.org/software/grub/manual/legacy
3. https://littleosbook.github.io
4. https://wiki.osdev.org
