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

To compile the assembler you can run followinf commands:

.. code-block:: bash

  as -o main.o main.S
  ld --oformat binary -o kernel.bin -Ttext 0x7C00 main.o

We have two important flags here:

1.  --oformat binary: output raw binary assembly code, don't warp it inside an ELF file as is the case for regular userland executables.

2. -Ttext 0x7C00: we need to tell the linker ld where the code will be placed so that it will be able to access the memory.

For this we would usually write a linker script. Now that we have the "kernel" we can build an iso.

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



Development environment
=======================
We will be building and installing a lot of tools rather frequently and many things can go wrong.
To make our life easier we can use virtual machines and to make everything even more hassle free,
we can utilize virtual machine manager, such as vagrant. 

Building the box
~~~~~~~~~~~~~~~~
Installing virtualbox and vagrant on Debian 9 is rather straightforward:

::

    # add stretch-backports main and contrib to your apt sources
    sudo apt install virtualbox
    wget https://releases.hashicorp.com/vagrant/2.1.1/vagrant_2.1.1_x86_64.deb
    sudo dpkg -i vagrant_2.1.1_x86_64.deb

[1] https://en.wikipedia.org/wiki/X86
https://www.gnu.org/software/grub/manual/legacy
https://littleosbook.github.io