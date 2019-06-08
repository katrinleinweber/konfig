#!/usr/bin/env bash

# Semi-automatically update cran.r-project.org/web/packages/ links to /package=

set -eux -o pipefail
# learned from https://codeinthehole.com/tips/bash-error-reporting/

DEPTH=1
#OWNER=$(echo "$1" | cut -f 1 -d /)
REPO=$(echo "$1" | cut -f 2 -d /)

cd ~/forks
gfork --depth="$DEPTH" "$1"

# prepare pull request on GitHub
cd "$REPO" || exit 1
(
BASE=$(git branch --list | head -1 | sed -E 's/ *//')
BRANCH=canonicalize-cran-links
git checkout -b "$BRANCH"

# learned from https://stackoverflow.com/a/19861378
rg \
  -g '!*/{src/test,src/main/resources}/*' \
  -g '!*.{pdf,zip}' \
  -e 'web/packages/' \
  --files-with-matches | \
  xargs -I@ perl -i -pe \
  's/web\/packages\/(?!available_packages_by_\w+)(?!packages\.rds)(\w+)(\/index\.html|\/\1\.pdf)?/package=\1/g' @
# https://regexr.com/4ddng

# rg \
#   -e 'http://cran' \
#   --files-with-matches | \
#   xargs -I@ perl -i -pe \
#   's/http(?=:\/\/cran)/https/g' @
  

# Create pull request
MSG='Canonicalize CRAN links'

#See https://cran.r-project.org/doc/manuals/R-exts.html#Specifying-URLs'
git commit --all --message "$MSG"

htmlproofer "$(git diff-tree --no-commit-id --name-only -r HEAD)"

git push --set-upstream origin "$BRANCH"
ME=$(git remote get-url origin)
ME=$(echo "$ME" | cut -f 4 -d /)
open https://github.com/"$1/compare/$BASE...$ME:$BRANCH"

PR_DESC="[CRAN asks to use the `package=` URL variant](https://cran.r-project.org/doc/manuals/R-exts.html#Specifying-URLs) when linking to packages ;-) This PR results from a semi-automatic search-and-replace script and implements their suggestion."

# [ ] replace with https://github.com/Mergifyio/git-pull-request
# echo '{
# 	"title": "'$MSG'",
# 	"body": "'$PR_DESC'",
# 	"head": "'$ME:$BRANCH'",
# 	"base": "'$BASE'"
# }' > cran-pr.txt

echo "$PR_DESC" | pbcopy
)

# clean up
rm -rf "$REPO"

