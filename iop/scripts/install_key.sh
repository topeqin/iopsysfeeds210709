# this is a developer helper script to install the public ssh key in the created image

function install_key {

    mkdir -p files/etc/dropbear
    test -e ~/.ssh/id_dsa.pub && cat ~/.ssh/id_dsa.pub >>files/etc/dropbear/authorized_keys
    test -e ~/.ssh/id_rsa.pub && cat ~/.ssh/id_rsa.pub >>files/etc/dropbear/authorized_keys
    chmod 0644 files/etc/dropbear/authorized_keys

    echo "::sysinit:/etc/init.d/rcS S boot" >files/etc/inittab
    echo "::shutdown:/etc/init.d/rcS K shutdown" >>files/etc/inittab
    echo "tty/0::askfirst:/bin/ash --login" >>files/etc/inittab
    echo "ttyS0::askfirst:/bin/ash --login" >>files/etc/inittab

    echo Done
}

register_command "install_key" "Install the user's public ssh key in the created image"
