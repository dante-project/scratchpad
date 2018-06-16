#!/usr/bin/env bash
echo -e " [+] fetching updates"
apt-get update

echo -e " [+] building i686 elf tools"
cd /home/src
/bin/bash i686-elf-tools.sh

#cmake .

echo -e " [+] box up and running"
echo -e " [+] you can log in using vagrant ssh"