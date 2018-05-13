#!/usr/bin/env bash

# Semi-automatically update dx.doi.org links on Git{Hub|Lab} to https://doi.org.
#
# Usage:
# 1. Copy this gist into a local folder of yours (e.g. ~/forks/).
# 2. Make it executable with `chmod +x ~/path/to/clone-rm-dx.sh`
# 3. Add your Git{Hub|Lab} username here:
# 4. Find target repos on https://github.com/search?o=desc&q=dx.doi&s=indexed&type=Code&utf8=%E2%9C%93
# 5. Insepct the code: can `dx.doi.org` be savely updated? Inspect tests,
#    regular expression, etc. in particular. Only proceed if you are very sure
#    that you don't break anything, that you don't feel comfortable fixing.
# 6. Copy a repo's clone URL from its Git{Hub|Lab} page.
# 7. Fork the package's repo. On GitLab, wait for that to finish. On GitHub, you
#    can proceed right away. Curious, isn't it?
# 8. In a bash terminal, execute this script with `~/path/to/clone-rm-dx.sh
#      https://git.host.tld/user/repo.git`.
# 9. Switch back to your browser and start the pull/merge request.

set -eux -o pipefail
# learned from codeinthehole.com/tips/bash-error-reporting

REPO=`echo $1 | cut -f 2 -d /`

gfork --depth=2 $1
cd $REPO

# prepare pull/merge request on Git{Hub|Lab}
BRANCH=resolve-DOIs-securely
git checkout -b $BRANCH


# learned from https://stackoverflow.com/a/19861378
grep \
  --ignore-case \
  --files-with-matches \
  --recursive \
  --exclude '*.pdf|*.zip' \
  --extended-regexp 'https?://(dx\.)?doi\.org' \
  * | xargs -I@ sed -Ei '' \
  's_https?://(dx\.)?doi\.org_https://doi.org_g' @

# prepare pull/merge request on Git{Hub|Lab}
git add *
git commit -m "Hyperlink DOIs against preferred resolver"
git push -u origin $BRANCH
ME=echo `git remote get-url origin` | cut -f 4 -d /
open https://github.com/$1/compare/master...$ME:$BRANCH

rm -rf $REPO
