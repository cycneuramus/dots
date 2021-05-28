## System installation

On an Arch Linux live USB:

```
loadkeys [keymap]
ip link show
iwctl --passphrase "[wifi_password]" station [wifi_interface] connect "[ssid]"

curl -sL https://raw.githubusercontent.com/cycneuramus/alis/master/download.sh | bash
vim alis.conf

./alis.sh
./alis-reboot.sh
```

## System setup

On a fresh Arch Linux host:

```
curl https://raw.githubusercontent.com/cycneuramus/dots/master/.local/bin/dots-setup.sh > dots-setup.sh
chmod +x dots-setup.sh

./dots-setup.sh bootstrap master
rm dots-setup.sh

bash .local/bin/post-install.sh
```

---

N.B. Some files are encrypted, there are hard-coded paths, and nothing is tested for general compatibility outside of my environment; do not expect a working configuration. 
