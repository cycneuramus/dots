## System setup

On a fresh Debian host:

```
su -
apt install -y sudo
usermod -aG sudo [user]

chsh -s /bin/bash/ [user]
su [user]
cd

wget https://raw.githubusercontent.com/cycneuramus/dots/homeserver/bin/post-install.sh
chmod +x post-install.sh

./post-install.sh
rm post-install.sh

sudo reboot now

bin/borg-restore.sh
```

---

N.B. Some files are encrypted, there are hard-coded paths, and nothing is tested for general compatibility outside of my environment; do not expect a working configuration.
