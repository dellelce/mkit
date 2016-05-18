#!/bin/bash
#
# requirements:
#   wget    : download srcget & software
#   GNU tar : j option (bzip2)
#

### ENV ###

export TIMESTAMP="$(date +%H%M_%d%m%y)"
export WORKDIR="$PWD/mkit_workdir"
export SRCGET="$WORKDIR/srcget"
export PATH="$PATH:$SRCGET"
SRCLIST="sqlite3 m4 autoconf suhosin bison apr aprutil httpd openssl php pcre libxml2"
export BUILDDIR="$WORKDIR/build_${TIMESTAMP}"
export SRCDIR="$PWD/src_${TIMESTAMP}"
export srcget="0.0.5.5"  #  srcget version
export srcgetUrl="https://github.com/dellelce/srcget/archive"
export LOGSDIR="${WORKDIR}/logs"

## need to be more explicit here?
export prefix="${1:-$PWD}"

# test prefix for relative directory

[ ${prefix} != ${prefix#./} ] &&
{
  _prefix="${prefix#./}"
  prefix="${PWD}/${_prefix}"
}

export PATH="$prefix/bin:$PATH"

mkdir -p "$BUILDDIR"
mkdir -p "$LOGSDIR"
mkdir -p "$SRCDIR"

 . mkit.config.sh

### FUNCTIONS ###

 .  mkit.lib.sh

### MAIN ###

echo
echo "Install directory is ${prefix}"
echo

# download srcget
get_srcget || { echo "Failed getting srcget, exiting..."; exit 1; }

# download latest archives / builds name mapping
download || { echo "Download failed for one of the components"; exit 1; }

## Build steps

build_sqlite3 || exit 1

build_m4 || exit 1

build_autoconf || exit 1

build_bison || exit 1

build_pcre || exit 1

build_openssl || exit 1

build_apr || exit 1

build_aprutil || exit 1

build_libxml2 || exit 1

build_httpd || exit 1

build_php || exit 1

build_suhosin || exit 1

### EOF ###
