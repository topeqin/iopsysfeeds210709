# this is a developer helper script to install the public ssh key on host running dropbear

function ssh_install_key {
	if [ -e ~/.ssh/id_rsa.pub ]; then
		echo "Adding public RSA key to $1"
		KEY=`cat ~/.ssh/id_rsa.pub`
	elif [ -e ~/.ssh/id_dsa.pub ]; then
		echo "Adding public DSA key to $1"
		KEY=`cat ~/.ssh/id_dsa.pub`
	else
		echo "No public key found"
		exit 1
	fi
	ssh root@$1 "echo '$KEY' >> /etc/dropbear/authorized_keys" && echo ok
}

register_command "ssh_install_key" "Install the users public ssh key on host running dropbear"
