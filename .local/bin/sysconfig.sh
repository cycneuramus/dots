#!/bin/bash

if [[ ! -d $HOME/.local/bin || ! -d $HOME/.local/cfg || -z $(ls -a $HOME/.local/bin) || -z $(ls -a $HOME/.local/cfg ]]; then
	echo "Källmappar saknas, avbryter..."
	exit
fi 

# Install packages
sudo pacman -S --needed - < /home/antsva/.local/log/pkg-explicit.pacman
yay -S --needed - < /home/antsva/.local/log/pkg-explicit.aur

# Network automations
sudo ln -s /home/antsva/.local/bin/90-on-wifi.sh /etc/NetworkManager/dispatcher.d/90-on-wifi.sh && sudo chown root:root /etc/NetworkManager/dispatcher.d/90-on-wifi.sh

# Config files etc.
sudo ln -s /home/antsva/.local/cfg/30-libinput.conf /etc/X11/xorg.conf.d/30-libinput.conf
ln -s /home/antsva/.local/bin/autostart.sh /home/antsva/.config/autostart-scripts/autostart.sh
cp /home/antsva/.local/cfg/Nord.qss /home/antsva/.local/share/albert/org.albert.frontend.widgetboxmodel/themes/Nord.qss

# LaTeX
# sudo ln -s /etc/fonts/conf.avail/09-texlive-fonts.conf /etc/fonts/conf.d/09-texlive-fonts.conf
# fc-cache && mkfontscale && mkfontdir

# Sandboxing
if [[ $(which firejail) ]]; then
	if [[ $(which steam) ]]; then
		sudo ln -s /usr/bin/firejail /usr/local/bin/steam-native
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

# Touchpad gestures
if [[ $(which libinput-gestures) ]]; then
	ln -s /home/antsva/.local/cfg/libinput-gestures.conf /home/antsva/.config/libinput-gestures.conf
	sudo gpasswd -a $USER input
elif [[ $(which gebaar) ]]; then
	ln -s /home/antsva/.local/cfg/gebaard.toml /home/antsva/.config/gebaar/gebaard.toml
	sudo usermod -a -G input $USER
fi

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
if [[ ! $(which nss-mdns) ]]; then
	echo "Skrivarstöd: paketet 'nss-mdns' fattas."
fi

# Battery life for laptops
if [[ $(which auto-cpufreq) ]]; then
	sudo systemctl enable auto-cpufreq
fi
if [[ $(which tlp) ]]; then
	sudo systemctl enable tlp.service
fi

# Automatic screen brightness
if [[ $(which clight) ]]; then
	sudo systemctl enable clightd.service
fi

# Jack
# https://jackaudio.org/faq/linux_rt_config.html
sudo sed -i '/End of file/ i @audio          -       rtprio          95' /etc/security/limits.conf
sudo sed -i '/End of file/ i @audio          -       memlock         unlimited' /etc/security/limits.conf
