#!/bin/bash

set -e 

main() {
	initial-checks
	log-dir
	pkg-install-pacman
	pkg-install-aur
	grub-theme
	lightdm-theme
	power-management
	disable-system-beep
	sandboxing
	system-configs
	system-services
	user-services
	jack-setup
}

initial-checks() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ ! -d $HOME/.local/bin || ! -d $HOME/.local/cfg || -z $(ls -a $HOME/.local/bin) || -z $(ls -a $HOME/.local/cfg) ]]; then
		echo "Source folders missing"
		exit
	fi 

	# Bail out if running in chroot (otherwise `systemctl --user` commands will fail)
	if [[ "$(sudo stat -c %d:%i /)" != "$(sudo stat -c %d:%i /proc/1/root/.)" ]]; then
		echo "This script ought not to be run in a chroot"
		echo "Exiting..."
		exit
	fi
}

# Prepare log directory for various script outputs
log-dir() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ ! -d $HOME/.local/log ]]; then
		mkdir $HOME/.local/log
	fi
}

pkg-install-pacman() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ -f $HOME/.local/cfg/pacman.conf ]]; then
		sudo rm /etc/pacman.conf
		sudo ln -s /home/antsva/.local/cfg/pacman.conf /etc/pacman.conf
	fi

	sudo pacman -Syu

	# AUR helper
	if [[ ! $(which yay) ]]; then
		cd $HOME
		sudo pacman -S git base-devel --needed --noconfirm
		git clone https://aur.archlinux.org/yay.git
		cd yay
		makepkg -si
		cd $HOME
		sudo rm -r yay
	fi

	sudo pacman -S --needed - < $HOME/.local/cfg/pkg.pacman
}

pkg-install-aur() {
	echo ""
	echo $FUNCNAME
	echo ""

	# Prepare rust environment for building certain AUR packages
	if [[ $(which rustup) ]]; then
		rustup update stable
	fi

	yay -S --needed - < $HOME/.local/cfg/pkg.aur

	if [[ $(which signal-cli) ]]; then
		sudo archlinux-java fix
	fi
}

grub-theme() {
	echo ""
	echo $FUNCNAME
	echo ""
	
	if [[ -f /etc/default/grub && $(which grub-mkconfig) ]]; then
		sudo sed -i "s/GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=hidden/" /etc/default/grub
		sudo sed -i "s/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/" /etc/default/grub
		sudo grub-mkconfig -o /boot/grub/grub.cfg
	fi
}

lightdm-theme() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ $(which lightdm) && $(which lightdm-webkit2-greeter) && -d /usr/share/lightdm-webkit/themes/litarvan/ ]]; then
		sudo sed -i "s/#greeter-session=.*/greeter-session=lightdm-webkit2-greeter/" /etc/lightdm/lightdm.conf
		sudo sed -i "s/webkit_theme.*/webkit_theme = litarvan/" /etc/lightdm/lightdm-webkit2-greeter.conf
	fi
}

power-management() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ $(which acpid) ]]; then
		sudo systemctl enable acpid.service
		sudo systemctl start acpid.service
		sudo rm /etc/acpi/handler.sh
		sudo ln -s /home/antsva/.local/bin/handler.sh /etc/acpi/handler.sh
	fi

	if [[ -f /etc/systemd/logind.conf ]]; then
		sudo sed -i "s/#HandleLidSwitchExternalPower=.*/HandleLidSwitchExternalPower=ignore/" logind.conf
	fi
}

disable-system-beep() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ $(lsmod | grep pcspkr) ]]; then
		sudo modprobe -r pcspkr
		sudo rmmod pcspkr
	fi
	echo "blacklist pcspkr" | sudo tee /etc/modprobe.d/nobeep.conf
}

sandboxing() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ $(which firejail) ]]; then
		if [[ $(which steam) ]]; then
			if [[ ! -d $HOME/.firejail/steam ]]; then
				mkdir -p $HOME/.firejail/steam
			fi
			sudo ln -s /usr/bin/firejail /usr/local/bin/steam-runtime
			sudo ln -s /usr/bin/firejail /usr/local/bin/steam
		fi

		if [[ $(which wine) ]]; then
			sudo ln -s /usr/bin/firejail /usr/local/bin/wine
		fi

		if [[ $(which firefox) ]]; then
			sudo ln -s /usr/bin/firejail /usr/local/bin/firefox
		fi

		# Fix .desktop files
		firecfg --fix
	fi
}

system-configs() {
	echo ""
	echo $FUNCNAME
	echo ""

	sudo ln -s /home/antsva/.local/cfg/rfkill /etc/sudoers.d/rfkill
	sudo ln -s /home/antsva/.local/cfg/bluetooth /etc/sudoers.d/bluetooth
	sudo chown root:root /etc/sudoers.d/rfkill
	sudo chown root:root /etc/sudoers.d/bluetooth

	sudo ln -s /home/antsva/.local/bin/90-on-wifi.sh /etc/NetworkManager/dispatcher.d/90-on-wifi.sh 
	sudo chown root:root /etc/NetworkManager/dispatcher.d/90-on-wifi.sh

	sudo ln -s /home/antsva/.local/cfg/30-libinput.conf /etc/X11/xorg.conf.d/30-libinput.conf

	if [[ $(which tlp) && -f $HOME/.local/cfg/tlp.conf ]]; then
		sudo rm /etc/tlp.conf 
		sudo ln -s /home/antsva/.local/cfg/tlp.conf /etc/tlp.conf
	fi

	# To change backlight with xbacklight (via acpilight package)
	sudo usermod -aG video $USER
}

system-services() {
	echo ""
	echo $FUNCNAME
	echo ""

	sudo systemctl enable NetworkManager
	sudo systemctl start NetworkManager
	sudo systemctl enable bluetooth
	sudo systemctl start bluetooth

	if [[ $(which sshd) ]]; then
		sudo systemctl enable sshd
		sudo systemctl start sshd
	fi

	# Printer support
	if [[ $(which avahi-daemon) ]]; then
		sudo systemctl enable avahi-daemon.service
		sudo systemctl start avahi-daemon.service
	fi
	if [[ $(which cups-config) ]]; then
		sudo systemctl enable cups.service
		sudo systemctl start cups.service
	fi
	if [[ $(ls /usr/lib/libnss_mdns*) ]]; then
		sudo rm /etc/nsswitch.conf
		sudo ln -s /home/antsva/.local/cfg/nsswitch.conf /etc/nsswitch.conf
	fi

	if [[ $(which libinput-gestures) ]]; then
		sudo gpasswd -a $USER input
	elif [[ $(which gebaar) ]]; then
		ln -s /home/antsva/.local/cfg/gebaard.toml /home/antsva/.config/gebaar/gebaard.toml
		sudo usermod -a -G input $USER
	fi

	if [[ $(which tlp) ]]; then
		sudo systemctl enable tlp.service
		sudo systemctl start tlp.service
	fi

	if [[ $(which clight) ]]; then
		sudo systemctl enable clightd.service
		sudo systemctl start clightd.service
	fi
}

user-services() {
	echo ""
	echo $FUNCNAME
	echo ""

	# Wallpaper switcher
	if [[ -f $HOME/.config/systemd/user/wallpaper.timer ]]; then
		systemctl --user enable wallpaper.timer
		systemctl --user start wallpaper.timer
		
		# Set initial background
		systemctl --user start wallpaper.service
	fi

	# Trash auto-emptying
	if [[ -f $HOME/.config/systemd/user/trash.timer ]]; then
		systemctl --user enable trash.timer
		systemctl --user start trash.timer
	fi
}


jack-setup() {
	echo ""
	echo $FUNCNAME
	echo ""

	# https://jackaudio.org/faq/linux_rt_config.html
	sudo usermod -aG audio $USER
	sudo sed -i '/End of file/ i @audio          -       rtprio          95' /etc/security/limits.conf
	sudo sed -i '/End of file/ i @audio          -       memlock         unlimited' /etc/security/limits.conf
}

main
