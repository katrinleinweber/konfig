#!/usr/bin/env bash
set -eux -o pipefail
# learned from codeinthehole.com/tips/bash-error-reporting

### USAGE
# 1. go to download.lineageos.org
# 2. click on your device's manufacturer and model name
# 3. copy the link to the SHA265 (NOT to the .zip!)
# 4. run ./lineage-DL.sh $SHA_URL

SHA_URL="$1"
ZIP_URL=`echo $SHA_URL | cut -f 1 -d \?`
SHA_FILE=`basename $ZIP_URL .zip`.sha256

wget --continue $ZIP_URL
wget -O $SHA_FILE "$SHA_URL"

shasum -a 256 -c $SHA_FILE
rm $SHA_FILE
# if return != "OK" => rm `basename $ZIP_URL`
