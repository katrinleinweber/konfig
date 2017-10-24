#!/usr/bin/env bash

# gelernt von codeinthehole.com/tips/bash-error-reporting
set -eux -o pipefail

# gelernt von stackoverflow.com/questions/6245570#comment74304422_6245587
BRANCH=`git rev-parse --abbrev-ref HEAD`
BRANCH_WIP=`echo $BRANCH | sed -e "s;$BRANCH;$BRANCH-WIP;"`

git checkout -b $BRANCH_WIP
git commit --all --untracked-files -m "WIP-leaf"
git checkout $BRANCH
