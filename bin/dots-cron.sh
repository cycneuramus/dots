#!/bin/bash

. funktioner.sh

commit_msg=$(date +"%Y%m%d_%H%M%S")
git --git-dir=$HOME/.dots/ --work-tree=$HOME commit -a -m "$commit_msg"

push "Punktfiler har synkats på $(hostname)"
