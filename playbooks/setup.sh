#!/bin/bash
set -a
if [ -z $1 ]; then
	echo -e "Usage: \n bash setup.sh [OPTIONS]\n \n Available Options: \n      install           Install Cloud Native Core x86\n      install jetson    Install Cloud Native Core for Jetson\n      validate          Validate Cloud Native Core x86 only\n      uninstall         Uninstall Cloud Native Core"
	echo
	exit 1
fi

sudo ls > /dev/null

# Ansible Install
ansible_install() {
	os=$(cat /etc/os-release | grep -iw ID | awk -F'=' '{print $2}') 
	version=$(cat /etc/os-release | grep -i VERSION_CODENAME | awk -F'=' '{print $2}')
	if [[ $os == "ubuntu" && $version != "focal" ]]; then 
		echo "Installing Ansible"
        	sudo apt-add-repository ppa:ansible/ansible -y
        	sudo apt update
        	sudo apt install ansible sshpass -y
	elif [[ $os == "ubuntu" && $version == "focal" ]]; then
		echo "Installing Ansible"
		sudo apt update
        	sudo apt install ansible sshpass -y
	elif [ $os == "rhel*" ]; then
		version=$(cat /etc/os-release | grep VERSION_ID | awk -F'=' '{print $2}')
		if [ $version == "*7.*" ]; then
			sudo subscription-manager repos --enable rhel-7-server-ansible-2.9-rpms
			sudo yum install ansible -y
		elif [ $version == "*8.*" ]; then
			sudo subscription-manager repos --enable ansible-2.9-for-rhel-8-x86_64-rpms
			sudo yum install ansible -y
		fi
	fi
}
if ! hash sudo ansible 2>/dev/null
then 
	ansible_install
else
	echo "Ansible Already Installed"
	echo
fi

if [[ $2 == "jetson" ]]; then
	echo "Installing Cloud Native Core on Jetson"
        ansible-playbook -i hosts jetson-xavier.yaml
	echo
else
	if [ $1 == "install" ]; then
	echo
	echo Cloud Native Core Version $(cat cnc_values.yaml | awk -F':' '{print $2}' | head -n1)
	echo
	echo "Installing Cloud Native Core"
	ansible-playbook -i hosts prerequisites.yaml	
	ansible-playbook -i hosts cnc-installation.yaml
	elif [ $1 == "uninstall" ]; then
	echo
	echo "Unstalling Cloud Native Core"
        ansible-playbook -i hosts cnc-uninstall.yaml
	elif [ $1 == "validate" ]; then
	echo
	echo "Validating Cloud Native Core"
        ansible-playbook -i hosts cnc-validation.yaml
	else
	echo -e "Usage: \n bash setup.sh [OPTIONS]\n \n Available Options: \n      install     Install Cloud Native Core\n      validate    Validate Cloud Native Core\n      uninstall   Uninstall Cloud Native Core"
        echo
        exit 1
	fi
fi
