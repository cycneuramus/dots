Automated install from an Arch Linux live USB:

```
# loadkeys [keymap]       # Load keyboard keymap, eg. loadkeys es, loadkeys us, loadkeys de
# iwctl --passphrase "[WIFI_KEY]" station [WIFI_INTERFACE] connect "[WIFI_ESSID]"          # (Optional) Connect to WIFI network. _ip link show_ to know WIFI_INTERFACE.
# curl -sL https://raw.githubusercontent.com/cycneuramus/alis/master/download.sh | bash     # Download alis scripts
# vim alis.conf           # Edit configuration and change variables values with your preferences (system configuration)
# ./alis.sh               # Start installation
# ./alis-reboot.sh        # (Optional) Reboot the system, only necessary when REBOOT="false"
```

---

On a fresh Arch Linux host:

```
curl https://raw.githubusercontent.com/cycneuramus/dots/master/.local/bin/dots-setup.sh > dots-setup.sh
chmod +x dots-setup.sh

./dots-setup.sh bootstrap master
rm dots-setup.sh

.local/bin/post-install.sh
```

---

N.B. Some files are encrypted, there are hard-coded paths, and nothing is tested for general compatibility outside of my environment; do not expect a working configuration. 
