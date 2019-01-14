#!/usr/bin/env bash

# Semi-automatically update dx.doi.org links on GitHub to https://doi.org.
#
# Usage:
# 1. Copy this gist into a local folder of yours (e.g. ~/forks/).
# 2. Make it executable with `chmod +x ~/path/to/clone-rm-dx.sh`
# 3. Install the gfork Node.js package and its dependencies.
# 4. Find target repos on https://github.com/search?o=desc&q=dx.doi&s=indexed&type=Code&utf8=%E2%9C%93
# 5. Insepct the code: can `dx.doi.org` be savely updated? Inspect tests,
#    regular expression, etc. in particular. Only proceed if you are very sure
#    that you don't break anything, that you don't feel comfortable fixing.
# 6. Copy the repo's URL.
# 7. In a bash terminal, execute this script with `~/path/to/clone-rm-dx.sh ` followed by the URL.
# 8. Fill out the pull request form, explaining your changes.

set -eux -o pipefail
# learned from https://codeinthehole.com/tips/bash-error-reporting/

DEPTH=1
REPO=$(echo $1 | cut -f 2 -d /)

cd ~/forks
gfork --depth=$DEPTH $1
# git clone --depth=$DEPTH $1  # needs 'cut -f 5 -d /' above

# log size
log_repo_size(){
	BYTES=$(find $REPO/.git | xargs stat -f%z | awk '{ s+=$1 } END { print s }')
	COMMIT_ID=$(cd $REPO && git rev-parse HEAD) # learned from https://stackoverflow.com/questions/949314/
	echo "\"$(date -R)\",\"$COMMIT_ID\",\"$1\",\"$2\",$DEPTH,$BYTES" >> ~/shallow-clone-sizes.csv
}
log_repo_size $1 "shallow"

# prepare pull request on GitHub
cd $REPO
BASE=$(git branch --list | head -1 | sed -E 's/ *//')
BRANCH=resolve-DOIs-securely
git checkout -b $BRANCH

# learned from https://stackoverflow.com/a/19861378
rg \
  -g '!*/{src/test,src/main/resources}/*' \
  -g '!*.{pdf,zip}' \
  -e 'https?://(w+\.)?(dx\.)?doi\.org' \
  --files-with-matches | \
  xargs -I@ sed -Ei '' \
  's/https?:\/\/(w+\.)?(dx\.)?doi\.org\/(.*)/https:\/\/doi.org\/\3/g' @

# Start pull request
git commit --all -m "Hyperlink DOIs to preferred resolver"
git push --set-upstream origin $BRANCH
ME=$(echo $(git remote get-url origin))
ME=$(echo $ME | cut -f 4 -d /)
open https://github.com/$1/compare/$BASE...$ME:$BRANCH

# clean up
cd ..
rm -rf $REPO


# log size again
gfork $1
# git clone $1  # needs 'cut -f 5 -d /' above
DEPTH=$(cd $REPO && git rev-list --count HEAD)
log_repo_size $1 "full"
rm -rf $REPO
