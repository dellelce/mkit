#!/bin/bash
#
# requirements:
#   wget    : download srcget & software
#   GNU tar : j option (bzip2)
#

### ENV ###

export WORKDIR="$PWD"
export SRCGET="$WORKDIR/srcget"
export PATH="$PATH:$SRCGET"
export SRCTARGET="$PWD/src"
SRCLIST="apr aprutil httpd openssl php"
prefix="$HOME/i"
export TIMESTAMP="$(date +%H%M_%d%m%y)"
export BUILDDIR="$WORKDIR/build_${TIMESTAMP}"
export srcget="0.0.5"  #  srcget version
export LOGSDIR="${WORKDIR}/logs"

mkdir -p "$BUILDDIR"
mkdir -p "$LOGSDIR"

[ ! -d "$SRCTARGET" ] &&
{
  mkdir -p $SRCTARGET
  rc=$?
  [ $rc -ne 0 ] && exit $rc
}

### FUNCTIONS ###

# download srcget
get_srcget()
{
 wget -q -O ${srcget}.tar.gz https://github.com/dellelce/srcget/archive/${srcget}.tar.gz
 tar xzf ${srcget}.tar.gz 
 ln -sf srcget-${srcget} srcget
}

download()
{
 typeset pkg

 for pkg in $SRCLIST
 do
   fn=$(srcget.sh -n $pkg)
   echo $pkg " has been downloaded as: " $fn
   eval "fn_${pkg}=$fn"
 done
}

#
# get filename for given package
#
getfilename()
{
 typeset pkg="$1"

 [ -z "$pkg" ] && return 1

 eval echo "\$fn_${pkg}"
}


#
# xz
#
uncompress_xz()
{
 typeset fn="$1"

 [ ! -f "$fn" ] && return 1

 xz -dc < "${fn}" | tar xmf -
 rc=$?
 [ "$rc" -eq 0 ] && { dir=$(ls -d1t $PWD/* | head -1); [ -d "$dir" ] && echo $dir; return 0; }
 return $rc
}

#
# bz2
#
uncompress_bz2()
{
 typeset fn="$1"

 [ ! -f "$fn" ] && return 1

 tar xmjf  "${fn}"
 rc=$?
 [ "$rc" -eq 0 ] && { dir=$(ls -d1t $PWD/* | head -1); [ -d "$dir" ] && echo $dir; return 0; }
 return $rc
}

#
# gz
#
uncompress_gz()
{
 typeset fn="$1" rc=0 dir=""

 [ ! -f "$fn" ] && return 1

 tar xmzf "${fn}"
 rc=$?
 [ "$rc" -eq 0 ] && { dir=$(ls -d1t $PWD/* | head -1); [ -d "$dir" ] && echo $dir; return 0; }
 return $rc
}

#
#

save_srcdir()
{
 typeset dir="$1"

 [ 
}

#
#
uncompress()
{
 typeset id="$1"
 typeset fn="$2"

 [ ! -f "$fn" ] && return 1

 [ "$fn" != "${fn%.xz}" ] && { dir=$(uncompress_xz "${fn}"); return $?; }
 [ "$fn" != "${fn%.bz2}" ] && { dir=$(uncompress_bz2 "${fn}"); return $?; }
 [ "$fn" != "${fn%.gz}" ] && { dir=$(uncompress_gz "${fn}"); return $?; }

 echo "Can't handle $fn type"
 return 1
}

#
#

build_sanity_gnuconf()
{
 [ ! -d "$1" -o ! -f "$d/configure"] && return 1
}

build_logger()
{
 typeset logid="$1"

 cat >> "${logs}/${TIMESTAMP}_${logid}.log"
}

buildsdir()
{
 echo almost there
}

#
# Build  functions need to be executed from build directory
#
# all build here use GNU Configure
#

build_gnuconf()
{
 typeset rc_conf rc_make rc_makeinstall
 typeset id="$1"; shift   # build id
 typeset dir="$1"; shift  # src directory

 build_sanity_gnuconf $d || return $?

 {
  $dir/configure --prefix="${prefix}" $* 2>&1
  rc_conf=$?
 } | build_logger ${id}_configure

 [ "$rc_conf" -ne 0 ] && return $rc_conf

 {
  make 2>&1
  rc_make=$?
 } | build_logger ${id}_make

 [ "$rc_make" -ne 0 ] && return $rc_make

 {
  make install 2>&1 
  rc_makeinstall=$?
 } | build_logger ${id}_makeinstall

 return $rc_makeinstall
}

#
#
build_apr()
{
 typeset rc_conf rc_make rc_makeinstall
 build_sanity_gnuconf $1 || return $?
 $1/configure --prefix="${prefix}"
 rc_conf=$?
 make
 rc_make=$?
 make install 
 rc_makeinstall=$?
}

build_aprutil()
{
 build_sanity_gnuconf $1 || return $?
 build_gnuconf 
}

build_httpd()
{
 build_sanity_gnuconf $1 || return $?
 echo httpd
}

build_libxml2()
{
 build_sanity_gnuconf $1 || return $?
 echo libxml2
}

build_php()
{
 build_sanity_gnuconf $1 || return $?
 echo php
}

### MAIN ###

# download srcget
# get_srcget

# download latest archives / builds name mapping
#download


for x in *.bz2 *.gz *.xz
do
 [ ! -f "$x" ] && continue
 echo 
 echo $x
 echo
 uncompress $x
done


### EOF ###
