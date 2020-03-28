#!/usr/bin/env bash
set -eux -o pipefail
# learned from codeinthehole.com/tips/bash-error-reporting

DEPTH=1
REPO=$(echo "$1" | cut -f 2 -d /)


# echo "--------"
# echo $TYPO => $CORRECT
# echo "--------"

gfork --depth=$DEPTH "$1"

# log size
# $(~/.config/log_repo_size.sh)
# log_repo_size $1 "shallow-gc-pruned"

cd "$REPO"
BASE=$(git branch --list | head -1 | sed -E 's/ *//')
BRANCH=fix-typos
git checkout -b "$BRANCH"

# Correct each known typo
# https://stackoverflow.com/a/10929511/4341322

# while IFS='_' read TYPO CORRECT; do	
	# echo "Correcting '$TYPO' to '$CORRECT'..."	

TYPO="$2"
CORRECT="$3"

	# learned from https://stackoverflow.com/a/19861378
	# -g '!.git' \ not needed because ripgrep ignores hidden files

rg --files-with-matches \
	-g '!*.{pdf,zip}' \
	-e "$TYPO" | \
		xargs -I@ sed -Ei '' \
		"s_${TYPO}_${CORRECT}_g" @

# done < ~/.config/git/typos.txt

for f in *.md; do
	aspell check "$f"
done

# Start pull request
git commit --all -m "Fix typos"
git push --set-upstream origin $BRANCH
ME=$(git remote get-url origin | cut -f 4 -d /)
open https://github.com/"$1/compare/$BASE...$ME:$BRANCH"

# clean up
#cd ..
#rm -rf $REPO
