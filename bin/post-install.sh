#!/bin/bash

# ```
# apt install sudo -y
# usermod -aG sudo antsva
# 
# chsh -s /bin/bash antsva
# su antsva
#
# wget https://raw.githubusercontent.com/cycneuramus/dots/homeserver/bin/post-install.sh
# chmod +x post-install.sh
# ```

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
		jq 					\
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

	sudo groupadd docker
	sudo usermod -aG docker $USER

	sudo systemctl enable docker.service
	sudo systemctl enable containerd.service
}

unattended-upgrades() {
	echo ""
	echo $FUNCNAME
	echo ""

	echo "APT::Periodic::Update-Package-Lists \"1\";APT::Periodic::Unattended-Upgrade \"1\";" \
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
		sudo rm /etc/default/tlp 
		sudo cp $HOME/bak/tlp.bak /etc/default/tlp
	fi

	if [[ -f /etc/sysctl.conf && -f $HOME/bak/sysctl.conf.bak ]]; then
		sudo rm /etc/sysctl.conf
		sudo cp $HOME/bak/sysctl.conf.bak /etc/sysctl.conf
	fi

	if [[ -f $HOME/bak/adguardhome.conf.bak ]]; then
		if [[ ! -d /etc/systemd/resolved.conf.d ]]; then
			sudo mkdir -p /etc/systemd/resolved.conf.d
		fi

		sudo cp $HOME/bak/adguardhome.conf.bak /etc/systemd/resolved.conf.d/adguardhome.conf
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

	sudo mkdir /mnt/extern
	echo "UUID=64073cce-9b55-4231-af58-cf0b0206ecc2 /mnt/extern ext4 defaults,nofail,x-systemd.device-timeout=4,auto,users,rw 0 2" \
		| sudo tee -a /etc/fstab
}

main
