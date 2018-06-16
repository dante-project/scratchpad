#!/usr/bin/env bash
touch status.log
function log() {
    if [ "$QUIET" = "1" ]; then
        "$@" >> status.log 2>&1
    else
        "$@" 2>&1 | tee -a status.log
    fi
}

log date
log echo -e " [+] fetching updates"
apt-get update

log echo -e " [+] building i686 elf tools"
cd /home/src
/bin/bash i686-elf-tools.sh

#cmake .

log echo -e " [+] box up and running"
log echo -e " [+] you can log in using vagrant ssh"
log date