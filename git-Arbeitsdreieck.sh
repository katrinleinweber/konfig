#!/usr/bin/env bash

# erste Version & Erklärung auf:
# gist.github.com/katrinleinweber/f89a07bda89bd9f98b34a831b8c2105a

set -eux -o pipefail
# learned from codeinthehole.com/tips/bash-error-reporting

UPSTREAM=$1
ME=katrinleinweber

git clone \
	--depth=1 \
	--origin upstream \
	$UPSTREAM 

cd `echo $UPSTREAM | cut -f 5 -d / | cut -f 1 -d .` 

# construct URL of my fork & set as origin
UP_USR=`echo $UPSTREAM | cut -f 4 -d /`
ORIGIN=`echo $UPSTREAM | sed "s;//;//$ME@;"`
ORIGIN=`echo $ORIGIN | sed -e "s;$UP_USR;$ME;"`
git remote add origin $ORIGIN
