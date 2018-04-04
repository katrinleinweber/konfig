#!/usr/bin/env bash

# gelernt von codeinthehole.com/tips/bash-error-reporting
set -eux -o pipefail

# gelernt von stackoverflow.com/questions/6245570#comment74304422_6245587
BRANCH=`git rev-parse --abbrev-ref HEAD`

APPEND=WIP-leaf

git checkout -b `echo $BRANCH-$APPEND`
git commit --all --untracked-files -m "$APPEND"
git checkout $BRANCH
