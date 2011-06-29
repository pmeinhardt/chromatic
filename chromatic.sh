#!/bin/bash


# config.
TMP_DIR="/tmp/chromium-latest"
DIST_URI="http://build.chromium.org/f/chromium/snapshots/Mac"


# output formatting.
STD='\033[0m'
BOLD='\033[01m'
BLUE='\033[34m'
RED='\033[31m'


# usage (currently takes no args).
if test $# -gt 0; then
  echo "Usage: ./chromatic.sh"
  exit 0
fi


# create update dir.
if test -d $TMP_DIR; then
  echo -e "${RED}Update directory ${TMP_DIR} already exists.${STD}"
  echo -en "Continue anyway? [Y/n] "
  read -n 1 CONTINUE
  echo 
  test $CONTINUE = 'Y' || exit -1
fi

mkdir -p $TMP_DIR && cd $TMP_DIR

# fetch latest revision number.
curl $DIST_URI/LATEST -o $TMP_DIR/LATEST --silent && LATEST=`cat ${TMP_DIR}/LATEST`
if ! test $LATEST; then
  echo -e "${RED}Could not connect to server.${STD}"
  exit -1
fi

echo -e "Latest build version: ${BLUE}${LATEST}${STD}."

# check installed version.
PLIST_FILE="/Applications/Chromium.app/Contents/Info.plist"
if test -f $PLIST_FILE; then
  INSTALLED=`/usr/libexec/PlistBuddy -c "Print SVNRevision" ${PLIST_FILE}`
  if test $INSTALLED && test $LATEST = $INSTALLED; then
    echo "You're up to date."
    exit 0
  fi
fi

# load, unpack and install.
echo "Downloading..."
curl $DIST_URI/$LATEST/chrome-mac.zip -o $TMP_DIR/chrome-mac.zip --silent

echo "Unzipping..."
if ! test -f $TMP_DIR/chrome-mac.zip; then
  echo -e "${RED}Download failed.${STD}"
  exit -1
fi
unzip -qq $TMP_DIR/chrome-mac.zip
test -d /Applications/Chromium.app && mv /Applications/Chromium.app ~/.Trash
cp -R $TMP_DIR/chrome-mac/Chromium.app /Applications


echo "Cleanup..."
rm -rf $TMP_DIR


# restart?
echo -en "Restart? [Y/n] "
read -n 1 RESTART
echo 
if test $RESTART = 'Y'; then
  if ps -ax | grep -v grep | grep Chromium > /dev/null; then
    killall TERM Chromium
  fi
  while ps -ax | grep -v grep | grep Chromium > /dev/null; do
    : # wait
  done
  open /Applications/Chromium.app
fi
