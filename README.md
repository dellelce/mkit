# mkit

[![Build Status](https://travis-ci.org/dellelce/mkit.svg?branch=master)](https://travis-ci.org/dellelce/mkit)

Download and Build (from source) complete stacks. The latest version available for each package is downloaded.

## Configuration variables

  * NO_TIMESTAMP: do not use a time stamp for "build" and "src" directories
  * KEEP_DOCS (Docker only): do not delete documentation directories.

## TODO:
  * Initial support for "hooks" added: they can be used for sanity checks and other tests. 
  * SANITY CHECKS: Test if basic pre-requisites: gcc/g++ are there (we are not going to installed them!)
  * NO: Test if a component is needed (missing on the system)
  * YES: Add ability to re-use installed system component (use installed pcre instead of downloading it)
  * Give more options (i.e. force download)
  * add a default "local install" directory ($HOME/.srcget maybe?)
  * Better & more options (there is only one now.... and it is not really optional!)
  * arguments: strip: do we need fat binaries in docker images (sometimes?)
  * arguments: debug builds: sometimes we need more symbols (-g2 etc)

## REQUIREMENTS:
  * gcc
  * g++ (several packages)
  * perl (> 5.10), Data/Dumper.pm (autotools, mostly for buil steps only)

