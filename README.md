chromatic.sh
===

Chromium browser updates on the fly

install
---

  1. `git clone git://github.com/pmeinhardt/chromatic-sh.git`
  2. `cd chromatic-sh`
  3. `make install`

This will simply copy the script as `/usr/local/bin/chromatic` and make it executable.

what it does
---

Once installed, chromatic can update your [Chromium](http://www.chromium.org/Home) installation with a single, convenient command: `chromatic`.

When run, chromatic will look for an updated revision of Chromium, downloading it if available. While doing so, you can safely continue browsing without interruption.

Once download and unpacking have finished, you can choose to restart Chromium or run the new version the next time you start your browser. Because Chromium remembers your opened tabs though, you'll have almost no off-time at all when restarting right away. _Boom!_

how it works
---

Chromatic basically automates these "[not-as-easy steps](http://www.chromium.org/getting-involved/download-chromium)", making 'em dead simple.
