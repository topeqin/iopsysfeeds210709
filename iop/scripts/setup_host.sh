#!/bin/bash

function install_pkgs()
{
    local packages_misc="
bison
build-essential
execstack
flex
g++
g++-multilib
gawk
gettext
git automake
gtk-doc-tools
liblzo2-dev
libncurses5-dev
ncurses-term
svn-buildpackage
uuid-dev
zlib1g-dev
"
    local packages_perl="libconvert-binary-c-perl libdigest-crc-perl"
    local packages_npm="npm nodejs yui-compressor"

    # do we need 32 bit compatibility libs ?
    if [ "$(uname -m | awk '{print$1}')" == "x86_64" ]; then
	local packages_x64="libc6-dev-i386 lib32z1"
    fi
    
    # filter out already installed packages
    local packages_all="$packages_misc $packages_perl $packages_x64 $packages_npm"
    local needed=""
    
    for pkg in $packages_all
    do
	if ! dpkg -s $pkg >/dev/null 2>/dev/null
	then
	    needed="$needed $pkg"
	fi
    done

    # install needed packages
    if [ -n "$needed" ]
    then
	echo "Need to install dpkg packages [$needed]"
	read -p "Do you approve installation of these packages (y/n): " ans
	if [ "$ans" == "y" ]; then
	    sudo apt-get install $needed
	else
	    echo "can't continue. aborting!"
	    exit 1
	fi
    fi
}


check_bash()
{
    local mysh=$(ls -hl /bin/sh | awk -F'[ ,/]' '{print$NF}')
    if [ "$mysh" != "bash" ]; then
	echo "On Debian based systems, e.g. Ubuntu, /bin/sh must point to bash instead of $mysh"
	read -p "Do you approve this change (y/n): " ans
	if [ "$ans" == "y" ]; then
	    sudo rm -f /bin/sh
	    sudo ln -s bash /bin/sh
	else
	    echo "Warning! You haven't pointed /bin/sh to bash."
	    exit 1
	fi
    fi
    
}

install_npm(){

    local npm_package="
bower
grunt-cli
less
mocha
npm
uglify-js
"
    local needed=""

    # Filter out already installed packages 
    for pkg in $npm_package
    do
	if ! npm list -g $pkg >/dev/null 2>/dev/null
	then
	    needed="$needed $pkg"
	fi
    done

    # install needed packages
    if [ -n "$needed" ]
    then
	echo "Need to install npm package $needed"
	for pkg in $needed
	do
	    sudo npm install -g $pkg
	done
    fi
}

check_brcm_tools(){

    local install_mips=0
    local install_arm=0
    
    if [ ! -d /opt/toolchains/crosstools-mips-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21 ]; then
	install_mips=1
	echo "Need to install broadcom MIPS toolchain"
    fi
    
    if [ ! -d /opt/toolchains/crosstools-arm-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21-NPTL ]; then
	install_arm=1
	echo "Need to install broadcom ARM toolchain"
    fi

    if [ $install_mips -eq 1 -o $install_arm -eq 1 ]; then
	read -p "Do you approve installation of missing toolchains (y/n): " ans
	if [ "$ans" == "y" ]; then
	    echo "Downloading toolchain"
	else
	    echo "can't continue. aborting"
	    exit 1
	fi

	# create install dir
	sudo mkdir -p /opt/toolchains/
	sudo chown $USER:$USER /opt/toolchains/

	(
	    mkdir tmp
	    cd tmp

	    wget http://iopsys.inteno.se/iopsys/toolchain/crosstools-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21.Rel1.2-full.tar.bz2
	    tar jxf crosstools-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21.Rel1.2-full.tar.bz2

	    if [ $install_mips -eq 1 ]; then
		echo "Installing MIPS toolchain"

		tar jxf crosstools-mips-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21.Rel1.2.tar.bz2
	    fi

	    if [ $install_arm -eq 1 ]; then
		echo "Installing ARM toolchain"
		tar jxf crosstools-arm-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21-NPTL.Rel1.2.tar.bz2
	    fi

	    rm -f crosstools-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21-sources.tar.bz2
	    rm -f crosstools-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21.Rel1.2-full.tar.bz2
	    rm -f crosstools-mip*-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21.Rel1.2.tar.bz2
	    rm -f crosstools-arm-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21-NPTL.Rel1.2.tar.bz2
	)
    fi
}

check_gcc_version(){

    gcc_ver=$(ls -l /usr/bin/gcc-[0-9]* | head -1 | awk '{print$NF}' | cut -d'-' -f2)
    if [ "$gcc_ver" != "4.8" ]; then
	echo "Your current gcc version is $gcc_ver, but it must be changed to 4.8"
	read -p "Do you approve this change (y/n): " ans
	if [ "$ans" == "y" ]; then
	    apt-get install gcc-4.8
	    apt-get install g++-4.8
	    apt-get install gcc-4.8-multilib

	    update-alternatives --install /usr/bin/g++ c++ /usr/bin/g++-4.8 100
	    update-alternatives --install /usr/bin/g++ c++ /usr/bin/g++-$gcc_ver 90

	    update-alternatives --install /usr/bin/gcc cc /usr/bin/gcc-4.8 100
	    update-alternatives --install /usr/bin/gcc cc /usr/bin/gcc-$gcc_ver 90

	    update-alternatives --install /usr/bin/cpp cpp /usr/bin/cpp-4.8 100
	    update-alternatives --install /usr/bin/cpp cpp /usr/bin/cpp-$gcc_ver 90

	    update-alternatives --set c++ /usr/bin/g++-4.8
	    update-alternatives --set cc  /usr/bin/gcc-4.8
	    update-alternatives --set cpp /usr/bin/cpp-4.8
	    ln -s /etc/alternatives/cc /usr/bin/cc 

	    echo "The deafult gcc version has now been changed from $gcc_ver to 4.8"
	else
	    cd $curdir
	    exit 1
	fi
    fi
}

function setup_host {

    #===============#
    # Prerequisites #
    #===============#

    install_pkgs
    check_bash
    install_npm
    check_brcm_tools
    check_gcc_version

    echo ""
    echo ""
    echo "You have successfully installed and configred prerequisites to be able to build an iopsys firmware"
    echo ""
    echo ""

}

register_command "setup_host" "Install needed packets to host machine"
