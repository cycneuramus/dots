#!/bin/bash

if [[ ! $(which git) ]]; then
	echo "git not found, aborting..."
	exit
fi

echo "Input remote repo:"
read remote_repo
echo "Input git username:"
read git_username
echo "Input git email:"
read git_email

if [[ $1 == "init" ]]; then

	echo "Initializing bare git repo..."
	git init --bare $HOME/.dots

	git --git-dir=$HOME/.dots/ --work-tree=$HOME remote add origin $remote_repo
	git --git-dir=$HOME/.dots/ --work-tree=$HOME config status.showUntrackedFiles no
	git --git-dir=$HOME/.dots/ --work-tree=$HOME remote set-url origin $remote_repo

	echo ""
	echo "All done. Now add the following alias to .bashrc:"
	echo "alias dots=\"git --git-dir=\$HOME/.dots/ --work-tree=\$HOME\""
	echo ""
	echo "Consider adding an encryption mechanism for sensitive files:"
	echo "https://github.com/elasticdog/transcrypt"
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

	cd $HOME
	git clone -b $2 --separate-git-dir=$HOME/.dots $remote_repo dots-tmp
	git clone https://github.com/elasticdog/transcrypt.git

	echo "Input transcrypt password:"
	read pass
	cd dots-tmp

	git status > /dev/null # prevents "dirty repo" complaints from transcrypt
	yes | ~/transcrypt/transcrypt -c aes-256-cbc -p "$pass"

	cd $HOME
	rsync --recursive --verbose --exclude '.git' dots-tmp/ $HOME/
	yes | rm -r dots-tmp/
	yes | rm -r transcrypt/


else
	echo "Usage: dots.sh [init]/[bootstrap branch]"
fi

git config --global credential.helper store # Save credentials after first login
git config --global user.name "$user_name"
git config --global user.email "$user_email"

# Usage after setup:

# dots add .bashrc
# dots commit -m 'Add bashrc'
# dots push

# Handy function designed for automation:
# Auto-generated commit message and 'commit -a' eliminates the need to 'dots add <changed file>' manually before each push 
# dots-sync() {
#     commit_msg=$(date +"%Y%m%d-%H%M%S")
# 
#     dots commit -a -m "$commit_msg"
#     dots push
# }
