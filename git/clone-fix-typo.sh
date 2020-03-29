#!/usr/bin/env bash
set -eux -o pipefail
# learned from codeinthehole.com/tips/bash-error-reporting

echo "Which filetype to you want to spell-check (without .):"
read -r FILETYPE

DEPTH=1
REPO=$(echo "$1" | cut -f 2 -d /)

# echo "--------"
# echo $TYPO => $CORRECT
# echo "--------"

cd ~/forks
gfork --depth=$DEPTH "$1"

# log size
# $(~/.config/log_repo_size.sh)
# log_repo_size $1 "shallow-gc-pruned"

cd "$REPO"
BASE=$(git branch --list | head -1 | sed -E 's/ *//')
BRANCH=proofread
git switch -c "$BRANCH"


for f in **/*."$FILETYPE"
	do aspell check $f
done

trash *.bak

git commit --all --message "Hyperlink DOIs to preferred resolver"
git push --set-upstream origin "$BRANCH" 2> GH.txt
open $(rg "pull/new" GH.txt | cut -f7 -d' ')

cd ..
trash "$REPO"
