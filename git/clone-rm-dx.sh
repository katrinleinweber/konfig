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
# 6. Copy the user- & repo name from its GitHub page in the top left. It has the form "username/reponame".
# 7. In a bash terminal, execute this script with `~/path/to/clone-rm-dx.sh username/reponame`.
# 8. Fill put the pull request form.

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
open https://github.com/$1/compare/master...$ME:$BRANCH

# clean up
rm -rf $REPO
