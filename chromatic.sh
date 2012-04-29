#!/bin/bash

# Configure paths.
SOURCE="http://commondatastorage.googleapis.com/chromium-browser-snapshots/Mac"
DESTINATION="/Applications/Chromium.app"
PLIST="$DESTINATION/Contents/Info.plist"
TMP="$HOME/Downloads"

# Where to redirect log messages, e.g. /dev/null for quiet mode.
out=/dev/tty

# Overwrite files and perform restarts without prompting.
force=

# Print the help text for chromatic.
#
# Returns nothing.
help()
{
  echo "chromatic [-fhluq]"
  echo "Options:"
  echo "  -f    do not prompt before overwriting files and restarting"
  echo "  -q    be quiet! no status messages on standard out"
  echo "  -l    log changes since the current revision"
  echo "  -u    undo last update (requires trashed .app to be present)"
  echo "  -h    you're looking at it"
}

# The latest available build revision number.
latest=""

# The revision number of the current build.
current=""

# Logs status messages to the configured output stream.
#
# Returns nothing.
log()
{
  echo $* >> $out
}

# Ask to confirm certain actions with a simple Yes or No choice.
#
# Example: confirm "Are you sure?"
# # => will display "Are you sure? [Y/n]" and immediately return after key-down
#
# Returns 0 (true) for input 'Y' else 1.
confirm()
{
  read -n 1 -p "$1 [Y/n]" -s && echo
  test $REPLY = 'Y'
}

# Download a remote file to a specified destination on the filesystem.
#
# Example: download http://.../chrome-mac.zip ~/Downloads/chrome-mac.zip
# # => downloads the URLs data into your downloads directory
#
# Returns curl's exit status.
download()
{
  curl -L $1 -o $2
}

# Unpacks an archive in its current directory.
#
# Example: unpack ~/Downloads/chrome-mac.zip
# # => unzips the archive's content into ~/Downloads
#
# Returns unzip's exit status.
unpack()
{
  unzip -qq $1 -d $(dirname $1)
}

# Moves a .app to the /Applications folder.
#
# Example: install ~/Downloads/Chromium.app
# # => puts the file into /Applications moving any previous version into Trash
#
# Returns nothing.
install()
{
  test -d /Applications/Chromium.app && mv /Applications/Chromium.app ~/.Trash
  mv $1 /Applications
}

# Undo the last update - requires trashed Chromium.app to be present.
#
# Returns 0 (true) on success, an error code otherwise.
undo()
{
  if [ ! -e ~/.Trash/Chromium.app ]; then
    echo "Could not undo last update"; return 1
  fi

  rm -rf ~/Applications/Chromium.app
  mv -f ~/.Trash/Chromium.app /Applications/Chromium.app
}

# Removes temporary files, i.e. those created while updating.
#
# Returns nothing.
cleanup()
{
  rm -rf $*
}

# Stop Chromium.
#
# Returns nothing.
stop()
{
  if ps -ax | grep -v grep | grep Chromium > /dev/null; then
    killall TERM Chromium
  fi
  while ps -ax | grep -v grep | grep Chromium > /dev/null; do
    : # wait
  done
}

# Start Chromium.
#
# Returns nothing.
start()
{
  open /Applications/Chromium.app
}

# Restart Chromium – opened tabs should be restored by the application.
#
# Returns nothing.
restart()
{
  stop && start
}

# Shows the list of changes between 2 given revisions in your default browser.
#
# Example: changelog 15734 134482
# # => opens the list of changes between rev 15734 and 134482
#
# Returns nothing.
changelog()
{
  open "http://build.chromium.org/f/chromium/perf/dashboard/ui/changelog.html?url=/trunk/src&mode=html&range=$1:$2"
}

# Run chromatic with the supplied arguments.
run()
{
  local args=$(getopt "fhluq" $*)

  local chnglog=

  for arg in $args; do
    case $arg in
      -f) force="force";;
      -q) out=/dev/null;;
      -l) chnglog="yes";;
      -u) undo; exit $?;;
      -h) help && exit 0;;
    esac
  done

  latest=$(curl -s $SOURCE/LAST_CHANGE)
  current=$(/usr/libexec/PlistBuddy -c "Print SVNRevision" $PLIST)

  if [ -z "$latest" ]; then
    log "Could not retrieve latest revision number" && exit 1
  fi

  if [ "$latest" = "$current" ]; then
    log "You're up to date" && exit 0;
  fi

  log "Latest build version: $latest"

  # Download the build.
  if [ -e $TMP/chrome-mac.zip ]; then
    log "Download file ${TMP}/chrome-mac.zip already exists."
    [ $force ] || confirm "Continue anyway?" || exit 0
  fi

  log "Downloading..."
  if ! download $SOURCE/$latest/chrome-mac.zip $TMP/chrome-mac.zip; then
    log "Download failed" && exit 1
  fi

  log "Unzipping..."
  if ! unpack $TMP/chrome-mac.zip; then
    log "Download failed" && exit 1
  fi

  log "Installing..."
  install $TMP/chrome-mac/Chromium.app

  log "Cleaning up"
  cleanup $TMP/chrome-mac.zip $TMP/chrome-mac

  if [ $force ] || confirm "Restart?"; then restart; fi

  if [ $chnglog ]; then changelog $current $latest; fi
}

# And go...
run $*
