#!/bin/bash

set -e

main() {
	home-dirs
	pkg-install
	dots-bootstrap
	grub
	power-management
	crontabs
	external-hd
	unattended-upgrades
	docker
	signal-cli
	system-configs
}

home-dirs() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ ! -d $HOME/log ]]; then
		mkdir $HOME/log
	fi

	if [[ ! -d $HOME/mnt ]]; then
		mkdir $HOME/mnt
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
		vainfo				\
		vim
}

dots-bootstrap() {
	echo ""
	echo $FUNCNAME
	echo ""

	wget https://raw.githubusercontent.com/cycneuramus/dots/master/.local/bin/dots-setup.sh
	chmod +x dots-setup.sh

	./dots-setup.sh bootstrap homeserver
	rm dots-setup.sh
}

grub() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ -f /etc/default/grub && -f /usr/sbin/update-grub ]]; then
		sudo sed -i "s/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/" /etc/default/grub
		sudo update-grub
	fi
}

power-management() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ -f /etc/systemd/logind.conf ]]; then
		sudo sed -i "s/#HandleLidSwitch=.*/HandleLidSwitch=ignore/" /etc/systemd/logind.conf
	fi

	if [[ $(command -v tlp) && -f /etc/default/tlp && -f $HOME/bak/tlp.bak ]]; then
		sudo apt install -y acpi-call-dkms
		
		sudo rm /etc/default/tlp 
		sudo cp $HOME/bak/tlp.bak /etc/default/tlp
		
		sudo systemctl enable tlp.service
		sudo systemctl start tlp.service
	fi
}

crontabs() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ -f $HOME/bak/crontab-antsva.bak ]]; then
		crontab $HOME/bak/crontab-antsva.bak
	fi

	if [[ -f $HOME/bak/crontab-root.bak ]]; then
		sudo crontab $HOME/bak/crontab-root.bak
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

	echo "options usb-storage quirks=0bc2:231a:" \
		| sudo tee -a /etc/modprobe.d/ext_hd_quirk.conf

	sudo update-initramfs -u
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
	sudo apt install -y \
		docker-ce 		\
		docker-ce-cli 	\
		docker-compose 	\
		containerd.io

	if ! grep -q "^docker:" /etc/group; then
		sudo groupadd docker
	fi
	sudo usermod -aG docker $USER

	# Fix for docker CE permahang blocking system shutdown
	if [[ -f /lib/systemd/system/docker.service ]]; then
		sudo sed -i "s/TimeoutSec=.*/TimeoutSec=60/" /lib/systemd/system/docker.service
		sudo systemctl daemon-reload
	fi

	sudo systemctl enable docker.service
	sudo systemctl enable containerd.service
}

signal-cli() {
	if [[ -f $HOME/bin/signal-cli-update.sh && ! -d $HOME/bin/signal-cli ]]; then
		$HOME/bin/signal-cli-update.sh
	fi
}

system-configs() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ -f $HOME/.terminfo/x/xterm-kitty ]]; then
		if [[ ! -d /etc/terminfo/x ]]; then
			sudo mkdir -p /etc/terminfo/x
		fi

		sudo cp $HOME/.terminfo/x/xterm-kitty /etc/terminfo/x/
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

	if [[ -f $HOME/bak/20-sysinfo.bak ]]; then
		if [[ -f /etc/motd ]]; then
			sudo rm /etc/motd
		fi

		sudo cp $HOME/bak/20-sysinfo /etc/update-motd.d/
		sudo chown root:root /etc/update-motd.d/20-sysinfo
		sudo chmod +x /etc/update-motd.d/20-sysinfo
	fi
}

main
