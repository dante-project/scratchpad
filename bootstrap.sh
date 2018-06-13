#!/usr/bin/env bash
echo -e " [+] fetching updates"
apt-get update

echo -e " [+] setting up tools"
cd /home/src
/bin/bash setup.sh

echo -e " [+] building the kernel"
#cmake .

echo -e " [+] box up and running"
echo -e " [+] you can log in using vagrant ssh"