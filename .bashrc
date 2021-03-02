PATH=$PATH:$HOME/bin

alias dots="git --git-dir=$HOME/.dots/ --work-tree=$HOME"

dots-sync() {
	commit_msg=$(date +"%Y%m%d-%H%M%S")
	dots commit -a -m "$commit_msg"
	dots push
}
