#!/bin/bash

SRC="http://commondatastorage.googleapis.com/chromium-browser-snapshots/Mac"
DST="/Applications/Chromium.app"
TMP="$HOME/Downloads"

# Colorize output.
RST="\033[0m"
RED="\033[31m"
BLU="\033[34m"

# Compare local and latest build numbers.
LATEST=$(curl -s $SRC/LAST_CHANGE)
PLIST=$DST/Contents/Info.plist
LOCAL=

if [ -z "$LATEST" ]; then
  echo -e "${RED}Could not connect to server.${RST}"
  exit 1
fi

echo -e "Latest build version: ${BLU}$LATEST${RST}."

if [ -f $PLIST ]; then
  LOCAL=$(/usr/libexec/PlistBuddy -c "Print SVNRevision" $PLIST)
fi

if [ ! -z "$LOCAL" ] && [ "$LATEST" = "$LOCAL" ]; then
  echo "You're up to date."
  exit 0
fi

# Download the build.
if [ -e $TMP/chrome-mac.zip ]; then
  echo -e "${RED}Download file ${TMP}/chrome-mac.zip already exists.${RST}"
  echo -en "Continue anyway? [Y/n] "
  read -n 1 CONTINUE
  echo
  test $CONTINUE = 'Y' || exit 0
fi

echo "Downloading..."
curl -L $SRC/$LATEST/chrome-mac.zip -o $TMP/chrome-mac.zip

# Unpack and install.
echo "Unzipping..."
if [ ! -e $TMP/chrome-mac.zip ]; then
  echo -e "${RED}Download failed.${RST}"
  exit 1
fi

unzip -qq $TMP/chrome-mac.zip -d $TMP
test -d /Applications/Chromium.app && mv /Applications/Chromium.app ~/.Trash
mv $TMP/chrome-mac/Chromium.app /Applications

# Clean up.
rm -rf $TMP/chrome-mac.zip $TMP/chrome-mac

# Restart?
echo -en "Restart? [Y/n] "
read -n 1 RESTART
echo

if [ $RESTART = 'Y' ]; then
  if ps -ax | grep -v grep | grep Chromium > /dev/null; then
    killall TERM Chromium
  fi
  while ps -ax | grep -v grep | grep Chromium > /dev/null; do
    : # wait
  done
  open /Applications/Chromium.app
fi
