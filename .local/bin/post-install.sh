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
	restore-backup
	diogenes-install
}

initial-checks() {
	echo ""
	echo $FUNCNAME
	echo ""

	# Bail out if running in chroot (otherwise `systemctl --user` commands will fail)
	if [[ "$(sudo stat -c %d:%i /)" != "$(sudo stat -c %d:%i /proc/1/root/.)" ]]; then
		echo "This script ought not to be run in a chroot"
		echo "Exiting..."
		exit
	fi

	if [[ ! -d $HOME/.local/bin || ! -d $HOME/.local/cfg || -z $(ls -a $HOME/.local/bin) || -z $(ls -a $HOME/.local/cfg) ]]; then
		echo "Source files missing"
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
	if [[ ! $(command -v yay) ]]; then
		cd $HOME
		sudo pacman -S git base-devel --needed --noconfirm
		git clone https://aur.archlinux.org/yay.git
		cd yay
		makepkg -sir --noconfirm
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
	if [[ $(command -v rustup) ]]; then
		rustup update stable
	fi

	sed -i '/diogenes/d' $HOME/.local/cfg/pkg.aur
	yay -S --needed - < $HOME/.local/cfg/pkg.aur

	if [[ $(command -v signal-cli) ]]; then
		sudo archlinux-java fix
	fi
}

grub-theme() {
	echo ""
	echo $FUNCNAME
	echo ""
	
	if [[ -f /etc/default/grub && $(command -v grub-mkconfig) ]]; then
		sudo sed -i "s/GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=hidden/" /etc/default/grub
		sudo sed -i "s/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/" /etc/default/grub
		sudo grub-mkconfig -o /boot/grub/grub.cfg
	fi
}

lightdm-theme() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ $(command -v lightdm) && $(command -v lightdm-webkit2-greeter) && -d /usr/share/lightdm-webkit/themes/litarvan/ ]]; then
		sudo sed -i "s/#greeter-session=.*/greeter-session=lightdm-webkit2-greeter/" /etc/lightdm/lightdm.conf
		sudo sed -i "s/webkit_theme.*/webkit_theme = litarvan/" /etc/lightdm/lightdm-webkit2-greeter.conf
	fi
}

power-management() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ $(command -v acpid) ]]; then
		sudo systemctl enable acpid.service
		sudo systemctl start acpid.service
		sudo rm /etc/acpi/handler.sh
		sudo ln -s /home/antsva/.local/bin/handler.sh /etc/acpi/handler.sh
	fi

	if [[ -f /etc/systemd/logind.conf ]]; then
		sudo sed -i "s/#HandleLidSwitchExternalPower=.*/HandleLidSwitchExternalPower=ignore/" /etc/systemd/logind.conf
	fi
}

disable-system-beep() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ $(lsmod | grep pcspkr) ]]; then
		sudo modprobe -r pcspkr
	fi

	echo "blacklist pcspkr" | sudo tee /etc/modprobe.d/nobeep.conf
}

sandboxing() {
	echo ""
	echo $FUNCNAME
	echo ""

	if [[ $(command -v flatpak) ]]; then
		if [[ ! $(command -v steam) ]]; then
			flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
			flatpak --user install flathub com.valvesoftware.Steam
		fi
	fi

	if [[ $(command -v firejail) ]]; then
		if [[ $(command -v steam) ]]; then
			if [[ ! -d $HOME/.firejail/steam ]]; then
				mkdir -p $HOME/.firejail/steam
			fi
			sudo ln -s /usr/bin/firejail /usr/local/bin/steam-runtime
			sudo ln -s /usr/bin/firejail /usr/local/bin/steam
		fi

		if [[ $(command -v wine) ]]; then
			sudo ln -s /usr/bin/firejail /usr/local/bin/wine
		fi

		if [[ $(command -v firefox) ]]; then
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

	if [[ $(command -v tlp) && -f $HOME/.local/cfg/tlp.conf ]]; then
		sudo rm /etc/tlp.conf 
		sudo ln -s /home/antsva/.local/cfg/tlp.conf /etc/tlp.conf
	fi

	if [[ ! -d /etc/pacman.d/hooks/ ]]; then
		sudo mkdir -p /etc/pacman.d/hooks
	fi
	if [[ -f $HOME/.local/cfg/polybar.hook ]]; then
		sudo ln -s /home/antsva/.local/cfg/polybar.hook /etc/pacman.d/hooks/polybar.hook
	fi

	if [[ ! -d /etc/udev/rules.d ]]; then
		sudo mkdir -p /etc/udev/rules.d
	fi
	if [[ -f $HOME/.local/cfg/95-battery.rules ]]; then
		sudo ln -s /home/antsva/.local/cfg/95-battery.rules /etc/udev/rules.d/95-battery.rules
	fi
	if [[ -f $HOME/.local/cfg/90-bluetooth.rules ]]; then
		sudo ln -s /home/antsva/.local/cfg/90-bluetooth.rules /etc/udev/rules.d/90-bluetooth.rules
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

	if [[ $(command -v sshd) ]]; then
		sudo systemctl enable sshd
		sudo systemctl start sshd
	fi

	# Printer support
	if [[ $(command -v avahi-daemon) ]]; then
		sudo systemctl enable avahi-daemon.service
		sudo systemctl start avahi-daemon.service
	fi
	if [[ $(command -v cups-config) ]]; then
		sudo systemctl enable cups.service
		sudo systemctl start cups.service
	fi
	if [[ $(ls /usr/lib/libnss_mdns*) ]]; then
		sudo rm /etc/nsswitch.conf
		sudo ln -s /home/antsva/.local/cfg/nsswitch.conf /etc/nsswitch.conf
	fi

	if [[ $(command -v libinput-gestures) ]]; then
		sudo gpasswd -a $USER input
	elif [[ $(command -v gebaar) ]]; then
		ln -s /home/antsva/.local/cfg/gebaard.toml /home/antsva/.config/gebaar/gebaard.toml
		sudo usermod -a -G input $USER
	fi

	if [[ $(command -v tlp) ]]; then
		sudo systemctl enable tlp.service
		sudo systemctl start tlp.service
	fi

	if [[ $(command -v clight) ]]; then
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

restore-backup() {
	echo ""
	echo $FUNCNAME
	echo ""

	. $HOME/.local/bin/secrets > /dev/null 2>&1
	export RESTIC_PASSWORD="$restic_pass"

	restic -r "$restic_repo" restore latest --verbose --target / 	\
		--include /home/antsva/.mozilla								\
		--include /home/antsva/.local/share/scli					\
		--include /home/antsva/.local/share/signal-cli				\
		--include /home/antsva/.thunderbird							\
		--include /home/antsva/.local/share/zotero					\
		--include /home/antsva/.zotero
}

diogenes-install() {
	echo ""
	echo $FUNCNAME
	echo ""

	latest_release=$(curl --silent "https://api.github.com/repos/pjheslin/diogenes/releases/latest" | jq -r .tag_name)
	wget https://github.com/pjheslin/diogenes/releases/download/$latest_release/diogenes-$latest_release.pkg.tar.xz

	pkg="diogenes-$latest_release.pkg.tar.xz"

	if [[ -f "$pkg" ]]; then
		sudo pacman -U --noconfirm diogenes-$latest_release.pkg.tar.xz
		rm "$pkg"
	else
		echo "Kunde inte hitta $pkg"
	fi
}

main
