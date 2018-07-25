#!/bin/bash
if [[ $1 == "build" ]]
then
    cmake --target scratchpados-kernel
fi

if [[ $1 == "docs" ]]
then
	cd docs
	make html
	exit 0
fi

if [[ $1 == "clean" ]]
then
	cd bin
    rm os.iso
	cd iso/boot
	rm kernel.bin
	cd ../..
    exit 0
fi

cp cmake-build-debug/kernel/kernel.bin bin/iso/boot/kernel.bin
cd bin
grub-mkrescue -o os.iso iso

if [[ $1 == "run" ]]
then
    qemu-system-i386 -cdrom os.iso
fi