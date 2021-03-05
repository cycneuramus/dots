#!/bin/bash


# Push message to phone
push() {
	. secrets
	curl -X POST "$gotify_server/message?token=$gotify_token" -F "message=$1" -F "priority=1"
}


# Fix imput signal from POD XT to Jack
a-in() {
	alsa_in -d hw:2
}


# Record to file via Jack
a-rec() {
	cd $HOME/Skrivbord && jack_capture -f ogg
}


# Notify when process done (for e.g. job monitoring)
alert-done() {
	until [[ ! $(pgrep "$1") ]]; do 
		sleep 5 
	done 
	paplay /usr/share/sounds/Oxygen-Im-New-Mail.ogg
	notify-send -t 10000 "$1" "Job done"
}


# Convert audio to .mp3
aud-mp3() {
	ffmpeg -i "$1" -vn -c:a mp3 -b:a 192k "${1%.*}.mp3"
}


# Convert audio to .ogg
aud-ogg() {
	ffmpeg -i "$1" -vn -c:a libopus -ab 192k "${1%.*}.ogg"
}


# Increase volume in audio file
aud-vol() {
	ffmpeg -i "$1" -filter:a "volume=10dB" "${1%.*}_vol.${1#*.}"
}


# Convert audio to .wav
aud-wav() {
	ffmpeg -i "$1" "${1%.*}.wav"
}


# Scan for virus and malware
av-scan() {
	sudo freshclam
	clamscan / -ril $LOG/clamav.log
}


# Toggle bluetooth
bt() { 
	if [[ $(bluetooth) == *off* ]]; then
		bluetooth on 
		bluetoothctl power on 
	else
		bluetooth off
	fi
}


# Workaround for bluetooth bug
bt-fix() {
	sudo modprobe -r btusb
	sleep 1
	sudo modprobe btusb
	bt
	sleep 1
	bt

	sudo modprobe -r btusb
	sleep 1
	sudo modprobe btusb
	bt
	sleep 1
	bt
}


# Quick how-to for given tool
cheat() {
	curl cheat.sh/$1
}


# Change CPU governor
cpu-gov() {
	if [[ $(grep "model name" /proc/cpuinfo) == *Intel* ]]; then
		if [[ $1 = performance || $1 = per ]]; then
			sudo cpupower frequency-set -g performance
		elif [[ $1 = powersave || $1 = pwr ]]; then
			sudo cpupower frequency-set -g powersave
		fi
	else
		echo "This operation requires an Intel processor"
	fi
}


# Convert e-book to .pdf
ebook-pdf() {
	ebook-convert "$1" "${1%.*}.pdf"
}


# Write photo date to metadata based on file name (e.g. IMG_20150101_120500.jpg)
et-date() { 
	for f in "$@"; do
		exiftool "-AllDates<FileName" -overwrite_original "$f"	 
	done
}


# Rename media files based on metadata dates (e.g. from IMG_1039.jpg to IMG_20150101_120500.jpg)
et-name() { 
	for f in "$@"; do
		# if [[ $f == IMG_* ]]; then
		if [[ $f == *.jp* ]]; then
			exiftool -d IMG_%Y%m%d_%H%M%S%%-c.%%e "-filename<DateTimeOriginal" "$f"
		elif [[ $f == *.mp* ]]; then
			exiftool -d VID_%Y%m%d_%H%M%S%%-c.%%e "-filename<DateTimeOriginal" "$f"
		fi
	done
}


# Scrub metadata from media file
et-scrub() {
	for f in "$@"; do
		exiftool -all= -overwrite_original "$f"
	done
}


# Shares file(s) with E2E encryption via Firefox Send
ffs() { 
	# Generera arkiv vid flertal filer
	if (( $# > 1 )); then
		zip="$(date +%s).zip"
		zip -j $zip "$@"
		payload="$zip"
	else
		payload="$1"
	fi

	ffsend upload --copy "$payload"
	if [[ -f $zip ]]; then rm $zip; fi
	echo "NB. link will expire after 24 hours"
}

# Find and replace a matching string in files recursively
find-replace() {
	echo "To find and replace a matching string in files recursively, edit and use the following command:"
	echo ""
	echo "grep --include={*.filetype1,*.filetype2} -rl . -e \"string-find\" | xargs sed -i 's/string-find/string-replace/g'"
}


# Compress jpeg
img-komp() {
	if (( $# < 2 )); then
		echo "Usage: img-komp [quality 1–100] [file]"
	else
		convert -compress jpeg -quality "$1" "$2" "${2%.*}_komp.${2#*.}"
	fi
}


# Change picture dimension to set values
img-resize() {
	if (( $# < 2 )); then
		echo "Usage: img-resize [file] [WIDTHxHEIGHT]"
	else
		convert "$1" -resize "$2"^ -gravity center -crop "$2"+0+0 +repage "${1%.*}_resized.${1#*.}"
	fi
}


# Test for internet connectivity
internet() { 
	# if wget -T 5 -q --spider http://kernel.org; then
	if ping -q -w1 -c1 kernel.org &>/dev/null; then
		echo "on"
	else
		echo "off"
	fi
}


# Get intenal IP
ip() {
	# ip a | grep 'inet 192' | awk '{ print $2 }'
	ip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

	# Correct results akin to "10.8.0.2 192.168.0.108" by removing all kind of spaces ([[:space]]) and anything before (*)
	if [[ $ip =~ [[:space:]]+ ]]; then
		ip="${ip//*[[:space:]]/}"
	fi
	
	echo $ip
}


# Check if laptop open or closed
lid() {
	if [[ $(upower -d | grep lid-is-closed | awk '{ print $2 }') = no ]]; then
		echo "open"
	else
		echo "closed"
	fi
}


# Get coordinates from external IP
loc() {
	ip_info=$(curl -s ifconfig.co/json)
	
	lat=$(echo "$ip_info" | grep latitude | grep -Eo '[0-9.]+')
	lon=$(echo "$ip_info" | grep longitude | grep -Eo '[0-9.]+')
	
	echo $lat,$lon
}


# Render markdown document to fancy .pdf
pdoc() {
	read -r firstline <"$1"
	if [[ "$firstline" == %* ]]; then
		pandoc -f markdown -t beamer "$1" -V theme:metropolis -V lang:sv -V mainfont="Source Sans Pro" -i --pdf-engine=tectonic -o "${1%.*}".pdf
	else
		# pandoc $PREAMBLE --filter pandoc-citeproc "$1" -o "${1%.*}".pdf --pdf-engine=xelatex --verbose
		pandoc $PREAMBLE --citeproc "$1" -o "${1%.*}".pdf --pdf-engine=tectonic --verbose
	fi
}

# Create .pdf from jpegs
pdf-img() {
	convert -compress jpeg -quality 1 ./*.jpg out.pdf
}


# Run OCR on .pdf
pdf-ocr() {
	# För engelskspråkig text med dubbelsidig layout
	pdfsandwich -lang eng "$1"
}


# Check updates for packages installed from Github
pkg-update-check() {
	if [[ $(internet) == off ]]; then exit; fi 
	repo="$1"
	pkg=$(echo $repo | sed 's:.*/::')

	log=$LOG/$pkg-update.log
	latest_release=$(curl --silent "https://api.github.com/repos/$repo/releases/latest" | jq -r .tag_name)

	if [[ -f $log && $latest_release != $(cat $log) ]]; then
		notify-send -t 60000 "Version $latest_release av $pkg finns tillgänglig"
	fi

	echo $latest_release > $log
}


# Check power source
pwr() {
	if [[ $(acpi) == *Charging* ]]; then
		echo ac
	else
		echo bat
	fi
}


# Search file contents interactively
rga-fzf() {
	rg_prefix="rga --files-with-matches"
	local file
	file="$(
		fzf_default_command="$rg_prefix '$1'" \
			fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
				--phony -q "$1" \
				--bind "change:reload:$rg_prefix {q}" \
				--preview-window="70%:wrap"
	)" &&
	echo "öppnar $file" &&
	xdg-open "$file"
}


# Toggle redshift
rs() {
	if [[ $1 = on ]]; then
		redshift -l $(loc | sed s/,/:/) -t 6500:3400 &
	elif [[ $1 = off ]]; then
		redshift -x && killall -9 redshift
	fi
}


# Check display status
scr() {
	if [[ $(xset -q | sed -ne 's/^[ ]*Monitor is //p') = "On" ]]; then
		echo "on"
	else
		echo "off"
	fi
}


# Generate qr for linking signal-cli to phone
signal-link() {
	signal-cli link -n signal-cli-$(hostname) > qr & sleep 5; qrencode -t ANSI $(cat qr)
}


# Send Signal message to self
signal-msg() {
	. secrets
	signal-cli -u $phone_number send -m "$1" $phone_number
}


# Send file to self via Signal
signal-file() {
	. secrets
	signal-cli -u $phone_number send -m "Från $(hostname)" $phone_number -a "$1"
}


# Get SSID
ssid() {
	nmcli con show -a | grep wifi | awk '{ print $1 }'
}


# Diamond hands
stonks() {
	tickrs -s GME,AMC,NOK,BB -x --summary
}


# Clear package cache etc.
sys-clean() {
	sudo pacman -Scc --noconfirm
	[[ $(sudo pacman -Qtdq) ]] && sudo pacman -Rns $(sudo pacman -Qtdq)
	sudo pacdiff
}


# Check if system is prevented from sleeping
system-sleep-inhibited() {
	qdbus org.freedesktop.PowerManagement /org/freedesktop/PowerManagement org.freedesktop.PowerManagement.Inhibit.HasInhibit
}


# Get CPU temperature
temp() {
	sed 's/...$/°C/' /sys/class/thermal/thermal_zone0/temp
}


# Increase brightness in video
vid-bright () {
	ffmpeg -i "$1" -vf eq=gamma=1.5:saturation=1.25:contrast=1.075 -c:a copy "${1%.*}_bright.${1#*.}"
	
	# Preview:
	# ffplay -vf eq=gamma=1.5:saturation=1.25:contrast=1.075 "$1"
}


# Rip DVD to .mp4
vid-dvdrip() {
	cat VTS_0*_*VOB | ffmpeg -i - -c:v libx264 -crf 25 $HOME/Skrivbord/rip.mp4
}


# Convert video to .gif
vid-gif() {
	ffmpeg -i "$1" -filter_complex "[0:v] fps=15,scale=320:-1,split [a][b];[a] palettegen [p];[b][p] paletteuse" -f gif - | gifsicle --colors=256 --optimize=3 --lossy=150 --no-extensions -o "${1%.*}.gif"
}


# Compress video with x265
vid-komp() {
	if [[ "$2" ]]; then
		quality="$2"
	else
		quality=30
	fi

	ffmpeg -i "$1" -c:v libx265 -c:a copy -x265-params crf="$quality" "${1%.*}_komp.${1#*.}"
	
	# ffmpeg -i "$1" -c:v libx264 -c:a copy -x264-params crf="$quality" "${1%.*}_komp.${1#*.}"
} 


# Rotate video
vid-rot() {
	if (( $# < 2 )); then
		echo "Usage: vid-rot [degrees] [file]"
	else
		ffmpeg -i "$2" -metadata:s:v rotate="$1" -codec copy "${2%.*}_rot.${2#*.}"
	fi
}


# Compress ideo heavily for sharing via IM (e.g. Signal)
vid-signal() {
	for f in "$@"; do
		ffmpeg -i "$f" -c:v libx264 -vf "scale=480:-2" -c:a copy -x264-params crf=30 "${f%.*}_komp.${f#*.}"
	done
}


# Stabilize video
vid-stab() {
	ffmpeg -i "$1" -vf vidstabdetect=stepsize=4:mincontrast=0:result=transforms.trf -f null -	 
	ffmpeg -i "$1" -vf vidstabtransform=smoothing=30:interpol=bicubic:input="transforms.trf",unsharp -acodec copy -vcodec libx265 "${1%.*}_stab.${1#*.}"

	# ffmpeg -i "$1" -vf vidstabdetect -f null -
	# ffmpeg -i "$1" -vf vidstabtransform=zoom=5:smoothing=10:input="transforms.trf" -acodec copy -vcodec libx265 "${1%.*}_stab.${1#*.}"
	rm transforms.trf
}


# Sync audio track in video
vid-aud-sync() {
	if (( $# < 2 )); then
		echo "syntax: vid-sync [file] [+/-s.ms (e.g. -2.25 = -2.25 seconds]"
	else
		ffmpeg -i "$1" -itsoffset "$2" -i "$1" -map 1:v -map 0:a -c copy "${1%.*}_sync.${1#*.}"
	fi
}


# Compress video to target size
vid-targetsize() {
	if (( $# < 2 )); then
		echo "Usage: vid-targetsize [file] [file size in MB]"
	else
		target_video_size_MB="$2"
		origin_duration_s=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$1")
		origin_audio_bitrate_kbit_s=$(ffprobe -v error -pretty -show_streams -select_streams a "$1" | grep -oP "(?<=bit_rate=).*(?=Kbit)")
		target_audio_bitrate_kbit_s=$origin_audio_bitrate_kbit_s # TODO for now, make audio bitrate the same
		target_video_bitrate_kbit_s=$(awk -v size="$target_video_size_MB" -v duration="$origin_duration_s" -v audio_rate="$target_audio_bitrate_kbit_s" 'BEGIN { print	( ( size * 8192.0 ) / ( 1.048576 * duration ) - audio_rate	) }')

		 # For testing:
		 # echo "Ljudtarget: $target_audio_bitrate_kbit_s"
		 # echo "Längd: $origin_duration_s"
		 # echo "Videotarget: $target_video_bitrate_kbit_s"

		 ffmpeg -y -i "$1" -c:v libx264 -b:v "$target_video_bitrate_kbit_s"k -pass 1 -an -f mp4 /dev/null && ffmpeg -i "$1" -c:v libx264 -b:v "$target_video_bitrate_kbit_s"k -pass 2 -c:a aac -b:a "$target_audio_bitrate_kbit_s"k "${1%.*}-$2mB.mp4"
	fi
}


# Increase volume in video
vid-vol() {
	if [[ "$2" ]]; then
		vol="$2"
	else
		vol=10
	fi
	ffmpeg -i "$1" -af "volume=${vol}dB" -c:v copy "${1%.*}_vol.${1#*.}"
}


# Start VM
vm() {
	qemu-system-x86_64 $HOME/.vm/win-10.qcow2 -enable-kvm -m 8G -smp cores=4 -cpu host
}


# VPN on/off
vpn() {
	if [[ $1 = on ]]; then

		# Wait for internet
		until [[ $(internet) == on ]]; do
			sleep 2
			count=$((count + 1))
			if (( count > 15 )); then break; fi
		done
		if [[ $(internet) == off ]]; then
			notify-send "VPN" "Interntanslutning saknas, avbryter"
			exit
		fi

		ssid=$(ssid)
		if [[ $ssid == "SJ" ]]; then
			vpn=pivpn
		else
			vpn=Wireguard
		fi
		nmcli con up id $vpn
	
		# Kill VPN if no internet
		if [[ $(nmcli con show -a | grep "Wireguard\|pivpn") ]]; then
			until [[ $(internet) == on ]]; do
				sleep 2
				count=$((count + 1))
				if (( count > 3 )); then break; fi
			done
			if [[ $(internet) == off ]]; then
				vpn av
				notify-send "VPN" "Inaktiverades pga. utebliven internetanslutning"
			fi
		fi

	elif [[ $1 == off ]]; then

		if nmcli con show -a | grep -q Wireguard; then
			vpn=Wireguard
		elif nmcli con show -a | grep -q pivpn; then
			vpn=pivpn
		fi
		nmcli con down id $vpn

	fi
}


# Temporary fix for local subnet matching that of VPN
vpn-fix() {
	if nmcli con show -a | grep -q pivpn; then
		sudo route add 192.168.1.94 dev tun0
	elif nmcli con show -a | grep -q Wireguard; then
		sudo route add 192.168.1.94 dev Wireguard
	fi
}


# Test Wi-Fi connection
wifi() {
	. /home/antsva/.local/bin/secrets # Full path b/c of system script (90-on-wifi.sh)

	ssid=$(ssid)
	# Case-sensitive matching off
	shopt -s nocasematch
	
	case $ssid in
		$wifi_home)
			wifi="home"
			;;
		$wifi_trusted)
			wifi="trusted"
			;;
		$wifi_public)
			wifi="public"
			;;
		$wifi_work)
			wifi="work"
			;;
		$wifi_hotspot)
			wifi="hotspot"
			;;
		"")
			wifi="off"
			;;
	esac
	
	# Case-sensitive matching on
	shopt -u nocasematch
	
	echo $wifi
}


# Download audio from YouTube
yta() {
	youtube-dl -x "$1" -o "$HOME/Hämtningar/%(title)s.%(ext)s"
}


# Stream YouTube video via VLC
yts() {
	youtube-dl -o - "$1" | vlc -
}


# Download YouTube video
ytv() {
	youtube-dl -o "$HOME/Hämtningar/%(title)s.%(ext)s" "$1"
}

# Kör funktion genom externt anrop, t ex: /abc/def/functions.sh wifi
# if [[ "$1" && "$2" ]]; then 
#	  "$1" "$2"
# elif [[ "$1" && ! "$2" ]]; then
#	  "$1"
# fi

# Kommenterar ut det ovanstående eftersom det gör att även variabler i föräldraskript av någon anledning försöker exekveras när detta bibliotek dras in som källa (. /abc/def/functions.sh). I datortillstånd.sh tolkas exempelvis variablerna "pre" respektive "post" som argument vid inläsning av detta bibliotek, så att elif-blocket i ovanstående villkor utvärderas som sant ($1 = pre/post, $2 ej satt) och skriptet alltså försöker köra en funktion som heter "pre" eller "post". Detta, och åtföljande felmeddelande, syns i det exemplet i loggen för systemd-suspend.service.

# Då poängen med ovanstående villkorsblock var att kunna köra funktionen bt() från en tangentbordsgenväg, utan att behöva skriva ett separat skript för enbart denna funktion, så arbetar jag runt problemet så här:
if [[ "$1" = "bt" && ! "$2" ]]; then
	bt
fi