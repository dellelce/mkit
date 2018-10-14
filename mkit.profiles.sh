#!/bin/bash

# TODO: automate build orders & list
profile_default()
{
 add_build m4
 add_build autoconf
 add_build libffi
 add_build ncurses
 add_build libbsd
 add_build expat
 add_build readline
 add_build sqlite3
 add_build bison
 add_build pcre
 add_build zlib
 add_build bzip2
 add_build openssl
 add_build apr
 add_build aprutil
 add_build libxml2
 add_build httpd

 [ "$PHP_NEEDED" == "1" ] &&
 {
  add_build php
  add_build suhosin
 }

 add_build python3
 add_build mod_wsgi

 run_build
 return $?
}

profile_redis()
{
 add_build redis
 run_build
 return $?
}

profile_python()
{
 add_build libffi ncurses zlib bzip2 readline
 add_build openssl sqlite3 expat libxml2
 add_build python3
 run_build
 return $?
}

profile_uwsgi()
{
 add_build libffi
 add_build ncurses
 add_build zlib
 add_build bzip2
 add_build readline
 add_build openssl
 add_build sqlite3
 add_build expat
 add_build libxml2
 add_build python3
 add_build uwsgi
 run_build
 return $?
}

profile_postgres()
{
 add_build libressl
 add_build libxml2
 add_build zlib
 add_build ncurses
 add_build readline
 add_build postgresql
 run_build
 return $?
}

profile_openvpn()
{
 add_build openssl
 add_build lzo
 #we don't want you "linuxpam"
 #add_build linuxpam
 add_build openvpn
 run_build
 return $?
}

profile_gcc()
{
 add_build binutils
 add_build gmp
 add_build mpfr
 add_build mpc
 add_build gcc
 run_build
 return $?
}

profile_varnish()
{
 # varnish needs python (">= 2.7") for generating some files
 # build time dependency only so these should not stay here...
 #
 add_build libffi ncurses zlib bzip2 readline
 add_build openssl sqlite3 expat libxml2
 add_build python3

 # temporary workaround for missing backtrace() in musl
 [ -f "/etc/alpine-release" ] &&
 {
   apk add --no-cache libexecinfo-dev
 }

 add_build pcre
 add_build ncurses
 add_build readline
 add_build varnish

 run_build
 return $?
}

profile_curl()
{
 add_build openssl
 add_build curl

 run_build
 return $?
}

profile_haproxy()
{
 add_build pcre
 add_build zlib
 add_build ncurses # needed by readline
 add_build readline # required by lua
 add_build openssl
 add_build lua
 add_build haproxy

 run_build
 return $?
}

### EOF ###
