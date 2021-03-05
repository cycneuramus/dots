#!/bin/bash

. secrets

if [[ ! $(which git) ]]; then
	echo "git not found, aborting..."
	exit
fi

remote_repo="$git_repo"
user_name="$git_username"
user_email="$email"

if [[ $1 == "init" ]]; then

	echo "Initializing bare git repo..."
	git init --bare $HOME/.dots

	git --git-dir=$HOME/.dots/ --work-tree=$HOME remote add origin $remote_repo
	git --git-dir=$HOME/.dots/ --work-tree=$HOME config status.showUntrackedFiles no
	git --git-dir=$HOME/.dots/ --work-tree=$HOME remote set-url origin $remote_repo

	git config --global credential.helper store # Save credentials after first login
	git config --global user.name "$user_name"
	git config --global user.email "$user_email"

	echo ""
	echo "All done. Now add the following alias to .bashrc:"
	echo "alias dots=\"git --git-dir=\$HOME/.dots/ --work-tree=\$HOME\""
	echo ""
	echo "Also consider creating a separate branch for this machine:"
	echo "dots checkout -b <branch-name>"


elif [[ $1 == "bootstrap" ]]; then

	if [[ -z $2 ]]; then
		echo "Expected remote branch as argument:"
		echo "dots.sh bootstrap <branch>"
		exit
	fi

	if [[ ! $(which rsync) ]]; then
		echo "rsync not found, aborting..."
		exit
	fi

	echo "Bootstrapping from branch "$2"..." 
	git clone -b $2 --separate-git-dir=$HOME/.dots $remote_repo dots-tmp

	rsync --recursive --verbose --exclude '.git' dots-tmp/ $HOME/
	rm --recursive dots-tmp

else
	echo "Usage: dots.sh [init]/[bootstrap branch]"
fi

# Usage:
# dots add .bashrc
# dots commit -m 'Add bashrc'
# dots push

# Handy function designed for automation (put in .bashrc):
# Auto-generated commit message and 'commit -a' eliminates the need to 'dots add <file>' manually before each push 
# dots-sync() {
#     commit_msg=$(date +"%Y%m%d-%H%M%S")
# 
#     dots commit -a -m "$commit_msg"
#     dots push
# }
