On a fresh Arch Linux host:

```
curl https://raw.githubusercontent.com/cycneuramus/dots/master/.local/bin/dots-setup.sh > dots-setup.sh
chmod +x dots-setup.sh

./dots-setup.sh bootstrap master
rm dots-setup.sh

.local/bin/post-install.sh
```
