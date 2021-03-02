#!/data/data/com.termux/files/usr/bin/bash

cd /data/data/com.termux/files
tar -zcvf /sdcard/data/termux-backup-$(date +%s).tar.gz home usr
cd -
