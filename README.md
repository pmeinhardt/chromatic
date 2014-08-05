# Automate Chromium browser updates with chromatic.

With chromatic you can easily install and update
[Chromium](http://www.chromium.org/Home) builds from the command-line.

## Installation

To install chromatic, you don't have to build anything (it's just a shell
script) or install any dependencies (everything should work out of the box
on OS X). You can simply grab the script and put it in your PATH somewhere.

To install from the GitHub repository, here's what you do:

  1. `git clone git://github.com/pmeinhardt/chromatic.git`
  2. `cd chromatic`
  3. `make install`

This will simply copy the script to `/usr/local/bin` and make it executable.

## Commands

The basic structure of any chromatic command is:

    chromatic [command [args]]

Calling `chromatic` without any arguments is equivalent to calling
`chromatic update`.

Available commands are:

### version

Running `chromatic version` will print the installed version details, e.g.
`Chromium 38.0.2114.0 (287358)`.

### info

Use `chromatic info` to view the changelog for a specific revision or range of
revisions:

    chromatic info 287358 287265  # => revisions 287358 to 287265
    chromatic info 287358         # => revision number 287358
    chromatic info                # => the installed revision

### install

Installs the build with the specified build number or the latest build
if called without passing a build number.

    chromatic install 287358
    chromatic install

### update

Running `chromatic update` fetches and installs the most recent build
(this is the default action).

### help

Prints the usage information and help message: `chromatic help`.

## How It Works

When installing or updating your Chromium build, chromatic basically follows
these steps for retrieving a snapshot as recommended by the Chromium Dev Team:
[http://www.chromium.org/getting-involved/download-chromium](http://www.chromium.org/getting-involved/download-chromium).

## Periodic Updates

You can schedule periodic updates just by using `launchd` or `cron` if you like:
[https://developer.apple.com/library/mac/documentation/macosx/conceptual/bpsystemstartup/chapters/ScheduledJobs.html](https://developer.apple.com/library/mac/documentation/macosx/conceptual/bpsystemstartup/chapters/ScheduledJobs.html).
