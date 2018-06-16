#!/bin/bash

BINUTILS_VERSION=2.28
GCC_VERSION=7.1.0
GDB_VERSION=8.0
OS=`uname`
# Get absolute path, will spawn a subshell then exit so our pwd is retained
SCRIPTROOT=$(cd "$(dirname $0)" && pwd)
BUILD_DIR=$SCRIPTROOT/build-i686-elf
mkdir -p build-i686-elf
export PATH="$BUILD_DIR/output/bin:$PATH"

set -e

if [ $# -eq 0 ]
then
        args="binutils gcc gdb"
else
        args=$@
fi

function main {
    installPackages
    installMXE
    downloadSources
    compileAll "linux"
}

function installPackages {
    
    log echoColor "Installing packages"

    sudo -E apt-get install git \
        autoconf automake autopoint bash bison bzip2 flex gettext\
        g++ gperf intltool libffi-dev libgdk-pixbuf2.0-dev \
        libtool libltdl-dev libssl-dev libxml-parser-perl make \
        openssl patch perl pkg-config python python3-sphinx scons \
        sed unzip wget xz-utils libtool-bin texinfo g++-multilib -y
}

function installMXE {

    log echoColor "Installing MXE"

    if [ ! -d "/opt/mxe/usr/bin" ]
    then
        log echoColor "    Cloning mxe and compiling mingw32.static GCC"
        cd /opt
        sudo -E git clone https://github.com/mxe/mxe.git
        cd mxe
        sudo make gcc

        echo "export PATH=/opt/mxe/usr/bin:$PATH" >> ~/.bashrc
        export PATH=/opt/mxe/usr/bin:$PATH
    else
       log echoColor "    mxe is already installed. You'd better make sure /opt/mxe/usr/bin is on your path!"
    fi
}

function downloadSources {
    mkdir -p $BUILD_DIR
    cd $BUILD_DIR
    
    log echoColor "Downloading all sources"
    
    downloadAndExtract "binutils" $BINUTILS_VERSION

    downloadAndExtract "gcc" $GCC_VERSION "http://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz"
    
    log echoColor "Downloading GCC prerequisites"
    
    # Automatically download GMP, MPC and MPFR. These will be placed into the right directories.
    # You can also download these separately, and specify their locations as arguments to ./configure
    cd ./linux/gcc-$GCC_VERSION
    ./contrib/download_prerequisites
    cd ../..
    
    downloadAndExtract "gdb" $GDB_VERSION    
}

function downloadAndExtract {
    name=$1
    version=$2
    override=$3
    
    pwd
    
    log echoColor "    Processing $name"
    
    if [ ! -f $name-$version.tar.gz ]
    then
        log echoColor "        Downloading $name-$version.tar.gz"
        
        if [ -z $3 ]
        then
            wget http://ftp.gnu.org/gnu/$name/$name-$version.tar.gz
        else
            wget $override
        fi
    else
        log echoColor "        $name-$version.tar.gz already exists"
    fi

    mkdir -p linux
    cd linux
    
    if [ ! -d $name-$version ]
    then
        log echoColor "        Extracting $name-$version.tar.gz"
        tar -xf ../$name-$version.tar.gz
    else
        log echoColor "        Folder $name-$version already exists"
    fi
    
    cd ..
}

function compileAll {

    log echoColor "Compiling all $1"
    
    cd $1
    
    mkdir -p output

    compileBinutils $1
    compileGCC $1
    compileGDB $1
    
    cd ..
}

function compileBinutils {    
    if [[ $args == *"binutils"* ]]; then
        log echoColor "    Compiling binutils [$1]"
    
        mkdir -p build-binutils-$BINUTILS_VERSION
        cd build-binutils-$BINUTILS_VERSION
        
        configureArgs="--target=i686-elf --with-sysroot --disable-nls --disable-werror --prefix=$BUILD_DIR/$1/output"
        
        # Configure
        log echoColor "        Configuring binutils (binutils_configure.log)"
        ../binutils-$BINUTILS_VERSION/configure $configureArgs >> binutils_configure.log
        
        # Make
        log echoColor "        Making (binutils_make.log)"
        make >> binutils_make.log
        
        # Install
        log echoColor "        Installing (binutils_install.log)"
        sudo make install >> binutils_install.log
        cd ..
    else
        log echoColor "    Skipping binutils [$1] as 'binutils' was ommitted from commandline args '$args'"
    fi
}

function compileGCC {
    if [[ $args == *"gcc"* ]]; then
    
        log echoColor "    Compiling gcc [$1]"

        mkdir -p build-gcc-$GCC_VERSION
        cd build-gcc-$GCC_VERSION
        
        configureArgs="--target=i686-elf --disable-nls --enable-languages=c,c++ --without-headers --prefix=$BUILD_DIR/$1/output"
        
        # Configure
        log echoColor "        Configuring gcc (gcc_configure.log)"
        ../gcc-$GCC_VERSION/configure $configureArgs >> gcc_configure.log
        
        # Make GCC
        log echoColor "        Making gcc (gcc_make.log)"
        make all-gcc >> gcc_make.log
        
        # Install GCC
        log echoColor "        Installing gcc (gdb_install.log)"
        sudo make install-gcc >> gcc_install.log
        
        # Make libgcc
        log echoColor "        Making libgcc (libgcc_make.log)"
        make all-target-libgcc >> libgcc_make.log
        
        # Install libgcc
        log echoColor "        Installing libgcc (libgcc_install.log)"
        sudo make install-target-libgcc >> libgcc_install.log
        
        cd ..
    else
        log echoColor "    Skipping gcc [$1] as 'gcc' was ommitted from commandline args '$args'"
fi
}

function compileGDB {
    if [[ $args == *"gdb"* ]]; then

        log echoColor "    Compiling gdb [$1]"
    
        configureArgs="--target=i686-elf --disable-nls --disable-werror --prefix=$BUILD_DIR/$1/output"
        
        mkdir -p build-gdb-$GDB_VERSION
        cd build-gdb-$GDB_VERSION
        
        # Configure        
        log echoColor "        Configuring (gdb_configure.log)"
        ../gdb-$GDB_VERSION/configure $configureArgs >> gdb_configure.log
        
        # Make
        log echoColor "        Making (gdb_make.log)"
        make >> gdb_make.log
        
        # Install
        log echoColor "        Installing (gdb_install.log)"
        sudo make install >> gdb_install.log
        cd ..
    else
        log echoColor "    Skipping gdb [$1] as 'gdb' was ommitted from commandline args '$args'"
    fi
}

function echoColor {
    echo -e "\e[96m$1\e[39m"
}

function log() {
    if [ "$QUIET" = "1" ]; then
        "$@" >> $SCRIPTROOT/status.log 2>&1
    else
        "$@" 2>&1 | tee -a $SCRIPTROOT/status.log
    fi
}

main
