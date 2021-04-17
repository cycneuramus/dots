#!/bin/bash

set -e 

main() {
	initial-checks
	log-dir
	pkg-install-pacman
	pkg-install-aur
	grub-theme
	lightdm-theme
	acpi-handler
	disable-system-beep
	deploy-config-files
	sandboxing
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

	if [[ -f /home/antsva/.local/cfg/pacman.conf ]]; then
		sudo rm /etc/pacman.conf
		sudo ln -s /home/antsva/.local/cfg/pacman.conf /etc/pacman.conf
	fi

	sudo pacman -Syu

	# AUR helper
	cd $HOME
	sudo pacman -S git base-devel --noconfirm
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si
	cd $HOME
	sudo rm -r yay

	sudo pacman -S --needed - < /home/antsva/.local/cfg/pkg.pacman
}

pkg-install-aur() {
	echo ""
	echo $FUNCNAME
	echo ""

	# Prepare rust environment for building certain AUR packages
	if [[ $(which rustup) ]]; then
		rustup update stable
	fi

	yay -S --needed - < /home/antsva/.local/cfg/pkg.aur

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

acpi-handler() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ $(which acpid) ]]; then
		sudo systemctl enable acpid.service
		sudo systemctl start acpid.service
		sudo rm /etc/acpi/handler.sh
		sudo ln -s /home/antsva/.local/bin/handler.sh /etc/acpi/handler.sh
	fi
}

disable-system-beep() {
	echo ""
	echo $FUNCNAME
	echo ""

	sudo modprobe -r pcspkr
	sudo rmmod pcspkr
	echo "blacklist pcspkr" | sudo tee /etc/modprobe.d/nobeep.conf
}

deploy-config-files() {
	echo ""
	echo $FUNCNAME
	echo ""

	# Allow passwordless commands (e.g. sudo rfkill block bluetooth)
	sudo ln -s /home/antsva/.local/cfg/rfkill /etc/sudoers.d/rfkill
	sudo ln -s /home/antsva/.local/cfg/bluetooth /etc/sudoers.d/bluetooth
	sudo chmod root:root /etc/sudoers.d/rfkill
	sudo chmod root:root /etc/sudoers.d/bluetooth

	# Network automations
	sudo ln -s /home/antsva/.local/bin/90-on-wifi.sh /etc/NetworkManager/dispatcher.d/90-on-wifi.sh && sudo chown root:root /etc/NetworkManager/dispatcher.d/90-on-wifi.sh

	# Touchpad settings
	sudo ln -s /home/antsva/.local/cfg/30-libinput.conf /etc/X11/xorg.conf.d/30-libinput.conf

	# TLP
	if [[ $(which tlp) ]]; then
		sudo rm /etc/tlp.conf 
		sudo ln -s /home/antsva/.local/cfg/tlp.conf /etc/tlp.conf
	fi
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

system-services() {
	echo ""
	echo $FUNCNAME
	echo ""

	# Networking
	sudo systemctl enable NetworkManager
	sudo systemctl start NetworkManager
	sudo systemctl enable bluetooth
	sudo systemctl start bluetooth

	# ssh
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
	if [[ $(which nss-mdns) ]]; then
		sudo rm /etc/nsswitch.conf
		sudo ln -s /home/antsva/.local/cfg/nsswitch.conf /etc/nsswitch.conf
	fi

	# Touchpad gestures
	if [[ $(which libinput-gestures) ]]; then
		sudo gpasswd -a $USER input
	elif [[ $(which gebaar) ]]; then
		ln -s /home/antsva/.local/cfg/gebaard.toml /home/antsva/.config/gebaar/gebaard.toml
		sudo usermod -a -G input $USER
	fi

	# Battery life for laptops
	if [[ $(which auto-cpufreq) ]]; then
		sudo systemctl enable auto-cpufreq
		sudo systemctl start auto-cpufreq
	fi
	if [[ $(which tlp) ]]; then
		sudo systemctl enable tlp.service
		sudo systemctl start tlp.service
	fi

	# Automatic screen brightness
	if [[ $(which clight) ]]; then
		sudo systemctl enable clightd.service
		sudo systemctl start clightd.service
	fi

	# To change backlight with xbacklight (via acpilight package)
	sudo usermod -aG video $USER
}

user-services() {
	echo ""
	echo $FUNCNAME
	echo ""

	# Wallpaper switcher
	if [[ -f $HOME/.config/systemd/user/wallpaper.timer ]]; then
		systemctl --user enable wallpaper.timer
		systemctl --user start wallpaper.timer
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
