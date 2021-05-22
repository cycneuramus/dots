#!/bin/bash

set -e

main() {
	log-dir
	pkg-install
	dots
	signal-cli
	docker
	unattended-upgrades
	system-configs
	grub
	external-hd
}

# Prepare log dir for various script outputs
log-dir() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ ! -d $HOME/log ]]; then
		mkdir $HOME/log
	fi
}

pkg-install() {
	echo ""
	echo $FUNCNAME
	echo ""

	sudo apt update
	sudo apt install -y		\
		black 				\
		borgbackup 			\
		curl 				\
		flake8 				\
		git 				\
		hdparm				\
		htop				\
		jq 					\
		openjdk-11-jre		\
		openssh-server		\
		python3 			\
		rclone 				\
		rsync 				\
		tlp 				\
		unattended-upgrades \
		vim
}

dots() {
	echo ""
	echo $FUNCNAME
	echo ""

	wget https://raw.githubusercontent.com/cycneuramus/dots/master/.local/bin/dots-setup.sh
	chmod +x dots-setup.sh

	./dots-setup.sh bootstrap homeserver
	rm dots-setup.sh
}

signal-cli() {
	if [[ -f $HOME/bin/signal-cli-update.sh && ! -d $HOME/bin/signal-cli ]]; then
		$HOME/bin/signal-cli-update.sh
	fi
}

docker() {
	echo ""
	echo $FUNCNAME
	echo ""

	sudo apt install -y 	\
		apt-transport-https \
		ca-certificates 	\
		gnupg 				\
		lsb-release

	curl -fsSL https://download.docker.com/linux/debian/gpg | \
		sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

	echo \
		"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
		$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	sudo apt update
	sudo apt install -y docker-ce docker-ce-cli docker-compose containerd.io

	if ! grep -q "^docker:" /etc/group; then
		sudo groupadd docker
	fi
	sudo usermod -aG docker $USER

	sudo systemctl enable docker.service
	sudo systemctl enable containerd.service
}

unattended-upgrades() {
	echo ""
	echo $FUNCNAME
	echo ""

	echo "APT::Periodic::Update-Package-Lists \"1\";
APT::Periodic::Unattended-Upgrade \"1\";
APT::Periodic::AutocleanInterval \"7\";" \
		| sudo tee -a /etc/apt/apt.conf.d/20auto-upgrades
}

system-configs() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ -f $HOME/bak/crontab-antsva.bak ]]; then
		crontab $HOME/bak/crontab-antsva.bak
	fi
	if [[ -f $HOME/bak/crontab-root.bak ]]; then
		sudo crontab $HOME/bak/crontab-root.bak
	fi

	if [[ -f /etc/systemd/logind.conf && -f $HOME/bak/logind.conf.bak ]]; then
		sudo rm /etc/systemd/logind.conf
		sudo cp $HOME/bak/logind.conf.bak /etc/systemd/logind.conf
	fi

	if [[ $(command -v tlp) && -f /etc/default/tlp && -f $HOME/bak/tlp.bak ]]; then
		sudo apt install -y acpi-call-dkms
		
		sudo rm /etc/default/tlp 
		sudo cp $HOME/bak/tlp.bak /etc/default/tlp
		
		sudo systemctl enable tlp.service
		sudo systemctl start tlp.service
	fi

	if [[ -f $HOME/bak/adguardhome.conf.bak && -d $HOME/docker/adguard-home ]]; then
		if [[ ! -d /etc/systemd/resolved.conf.d ]]; then
			sudo mkdir -p /etc/systemd/resolved.conf.d
		fi
		sudo cp $HOME/bak/adguardhome.conf.bak /etc/systemd/resolved.conf.d/adguardhome.conf

		if [[ -f /etc/resolv.conf ]]; then
			sudo mv /etc/resolv.conf /etc/resolv.conf.backup
			sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
		fi
	fi
}

grub() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ -f /etc/default/grub && $(ls /usr/sbin/update-grub) ]]; then
		sudo sed -i "s/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/" /etc/default/grub
		sudo update-grub
	fi
}

external-hd() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ ! -d /mnt/extern ]]; then
		sudo mkdir /mnt/extern
	fi

	echo "UUID=64073cce-9b55-4231-af58-cf0b0206ecc2 /mnt/extern ext4 defaults,nofail,x-systemd.device-timeout=4,auto,users,rw 0 2" \
		| sudo tee -a /etc/fstab
}

main
