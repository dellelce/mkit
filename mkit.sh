#!/bin/bash


### ENV ###

export SRCGET=$PWD/srcget
export PATH=$PATH:$SRCGET
export SRCTARGET="$PWD/src"
SRCLIST="apr aprutil httpd openssl php"
prefix="$HOME/i"


[ ! -d "$SRCTARGET" ] &&
{
  mkdir -p $SRCTARGET
  rc=$?
  [ $rc -ne 0 ] && exit $rc
}

### FUNCTIONS ###

get_srcget()
{
 typeset srcget="0.0.5"
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
# does not work for aprutil (filename begins with apr-util)
listfilenames()
{
 typeset fn item

 for item in $SRCLIST
 do
   eval echo "\$fn_${item}"
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

 echo xz -dc < "${fn}" | tar xf -
}

#
# bz2
#
uncompress_bz2()
{
 typeset fn="$1"

 [ ! -f "$fn" ] && return 1

 echo tar xvjf "${fn}" 
}

#
# gz
#
uncompress_gz()
{
 typeset fn="$1"

 [ ! -f "$fn" ] && return 1

 echo tar xvzf "${fn}" 
}

#
#
uncompress()
{
 typeset fn="$1"

 [ ! -f "$fn" ] && return 1

 [ "$fn" != "${fn%.xz}" ] && { uncompress_xz "${fn}"; return $?; }
 [ "$fn" != "${fn%.bz2}" ] && { uncompress_xz "${fn}"; return $?; }
 [ "$fn" != "${fn%.gz}" ] && { uncompress_xz "${fn}"; return $?; }

 echo "Can't handle $fn type"
 return 1
}

#
#
prepare_to_build()
{
  echo mini-build
}

#
#
#

build_sanity_gnuconf()
{
 [ ! -d "$1" -o ! -f "$d/configure"] && return 1
}

#
# Build  functions need to be executed from build directory
#
# all build here use GNU Configure
#

build_gnuconf()
{
 typeset rc_conf rc_make rc_makeinstall
 typeset id="$1"; shift
 typeset dir="$1"; shift

 build_sanity_gnuconf $d || return $?
 #
 $1/configure --prefix="${prefix}" $*
 rc_conf=$?

 #
 make
 rc_make=$?

 #
 make install 
 rc_makeinstall=$?
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
 echo aprutil
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


for x in *.bz2 *.gz
do
   uncompress $x
done



### EOF ###
