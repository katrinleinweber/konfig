#!/usr/bin/env bash
set -eux -o pipefail
# gelernt von codeinthehole.com/tips/bash-error-reporting

### Benutzung
# 1. browse zu download.lineageos.org
# 2. finde Hersteller und Modellnummer Deines Smartphones
# 3. kopiere den SHA256-Link (NICHT den zur .zip!)
# 4. tippe ./lineage-DL.sh ins Terminal
# 5. füge die SHA-URL ein
# 6. Bumm! Zack! Return!

SHA_URL="$1"
ZIP_URL=`echo $SHA_URL | cut -f 1 -d \?`
SHA_FILE=`basename $ZIP_URL .zip`.sha256

wget --continue $ZIP_URL
wget -O $SHA_FILE "$SHA_URL"

shasum -a 256 -c $SHA_FILE
rm $SHA_FILE

# [ ] Idee: Download löschen, wenn SHA-Summe nicht passt
# if return != "OK" => rm `basename $ZIP_URL`
