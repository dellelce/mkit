#!/bin/bash
#
# requirements:
#   wget    : download srcget & software
#   GNU tar : j option (bzip2)
#

### ENV ###

# built-in defaults
SRCLIST="sqlite3 m4 autoconf suhosin bison apr aprutil httpd openssl php pcre libxml2"
export srcget="0.0.5.5"  #  srcget version
export srcgetUrl="https://github.com/dellelce/srcget/archive"

# "external" options
 . mkit.config.sh

# 
export TIMESTAMP="$(date +%H%M_%d%m%y)"
export WORKDIR="$PWD/mkit_workdir"
export SRCGET="${WORKDIR}/srcget"
export PATH="$PATH:$SRCGET"
export DOWNLOADS="${WORKDIR}/downloads"
export BUILDDIR="${WORKDIR}/build_${TIMESTAMP}"
export SRCDIR="${WORKDIR}/src_${TIMESTAMP}"
export LOGSDIR="${WORKDIR}/logs"

## "prefix" is the usual "GNU prefix" option i.e. the root of our install
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
mkdir -p "$DOWNLOADS"

### FUNCTIONS ###

 .  mkit.lib.sh

### MAIN ###

echo
echo "Install directory is ${prefix}"
echo

# download srcget
get_srcget || { echo "Failed getting srcget, exiting..."; exit 1; }

# the next function (download) uses the variable SRCLIST to determine which packages to download
# TODO: check if perl is not installed at all?

eval $(getPerlVersions)

[ "$PERL_REVISION" -eq 5 -a "$PERL_VERSION" -lt 10 ] &&
{
 export SRCLIST="perl ${SRCLIST}"
 export PERL_NEEDED=1
 cat << EOF
   Detected version of perl is ${PERL_REVISION}.${PERL_VERSION}.${PERL_SUBVERSION} minimum required version is 5.10.
   Will download and build local version.

EOF
}

# download latest archives / builds name mapping
download || { echo "Download failed for one of the components"; exit 1; }

## Build steps

build_sqlite3 || exit $?

build_m4 || exit $?

build_autoconf || exit $?

build_bison || exit $?

build_pcre || exit $?

build_zlib || exit $?

[ "$PERL_NEEDED" -eq 1 ] &&
{
 build_perl
 rc=$?
 [ "$rc" -ne 0 ] && exit "$rc"
}

build_openssl || exit $?

build_apr || exit $?

build_aprutil || exit $?

build_libxml2 || exit $?

build_httpd || exit $?

[ "$PHP_NEEDED" == 1 ] &&
{
 build_php || exit $?

 build_suhosin || exit $?
}

build_readline || exit $?

build_python3 || exit $?

build_mod_wsgi || exit $?


### EOF ###
