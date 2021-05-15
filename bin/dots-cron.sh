#!/bin/bash

. functions.sh

commit_msg=$(date +"%Y%m%d_%H%M%S")
git --git-dir=$HOME/.dots/ --work-tree=$HOME commit -a -m "$commit_msg"

git --git-dir=$HOME/.dots/ --work-tree=$HOME push

push "Punktfiler har synkats på $(hostname)"
