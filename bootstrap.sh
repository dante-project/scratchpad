#!/usr/bin/env bash
function log() {
    if [ "$QUIET" = "1" ]; then
        "$@" >> status.log 2>&1
    else
        "$@" 2>&1 | tee -a status.log
    fi
}

touch status.log
:> status.log
log date

log echo -e " [+] fetching updates"
if [ `logname` = "vagrant" ]; then
    apt-get update
fi 

log echo -e " [+] building i686 elf tools"
if [ `logname` = "vagrant" ]; then
    cd /home/src
fi 

/bin/bash i686-elf-tools.sh

log echo -e " [+] building OS"
#/bin/bash build.sh build

log echo -e " [+] building docs"
/bin/bash build.sh docs

if [ `logname` = "vagrant" ]; then
    log echo -e " [+] box up and running"
	log echo -e " [+] you can log in using vagrant ssh"
else
	log echo -e " [+] Done!"
fi 
log date