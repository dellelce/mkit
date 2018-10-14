# mkit

[![Build Status](https://travis-ci.org/dellelce/mkit.svg?branch=master)](https://travis-ci.org/dellelce/mkit)

Download and Build (from source) complete stacks. The latest version available for each package is downloaded.

## Configuration variables

  * NO_TIMESTAMP: do not use a time stamp for "build" and "src" directories
  * KEEP_DOCS (Docker only): do not delete documentation directories.

## TODO:
  * SANITY CHECKS: Test if basic pre-requisites: gcc/g++ are there (we are not going to installed them!)
  * NO: Test if a component is needed (missing on the system)
  * YES: Add ability to re-use installed system component (use installed pcre instead of downloading it)
  * Give more options (i.e. force download)
  * Test if after "make install" component is actually there 
  * add a default "local install" directory ($HOME/.srcget maybe?)
  * Better & more options (there is only one now.... and it is not really optional!)
  * arguments: profile name (examples: http slim, http-php, http-python, etc)
  * arguments: nodocs: do not build docs! do we need them in production or in a docker image?
  * arguments: strip: do we need fat binaries in docker images (sometimes?)
  * arguments: debug builds: sometimes we need more symbols (-g2 etc)

## REQUIREMENTS:
  * gcc
  * g++ (pcre)
  * perl (> 5.10), Data/Dumper.pm

