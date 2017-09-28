#!/usr/bin/env bash
set -e

UPSTREAM=$1
ME=katrinleinweber

git clone \
	--depth=1 \
	--no-single-branch \
	--origin upstream \
	$UPSTREAM 

REPO=`echo $UPSTREAM | cut -f 5 -d / | cut -f 1 -d .` 
cd $REPO

# construct URL of my fork & set as origin
UP_USR=`echo $UPSTREAM | cut -f 4 -d /`
ORIGIN=`echo $UPSTREAM | sed "s;//;//$ME@;"`
ORIGIN=`echo $ORIGIN | sed -e "s;$UP_USR;$ME;"`
git remote add origin $ORIGIN
