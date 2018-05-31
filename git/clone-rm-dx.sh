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
# learned from codeinthehole.com/tips/bash-error-reporting

REPO=$(echo $1 | cut -f 2 -d /)

gfork --depth=2 $1
cd $REPO

# prepare pull request on GitHub
BRANCH=resolve-DOIs-securely
git checkout -b $BRANCH

# learned from https://stackoverflow.com/a/19861378
rg -g '!*.{pdf,zip}' \
  -e 'https?://(dx\.)?doi\.org' \
  --files-with-matches | \
  xargs -I@ sed -Ei '' \
  's_https?://(dx\.)?doi\.org_https://doi.org_g' @

# Start pull request
git commit --all -m "Hyperlink DOIs against preferred resolver"
git push --set-upstream origin $BRANCH
ME=$(echo $(git remote get-url origin))
ME=$(echo $ME | cut -f 4 -d /)
BASE=$(git branch --list | head -1)
open https://github.com/$1/compare/$BASE...$ME:$BRANCH

# clean up
cd ..
rm -rf $REPO
