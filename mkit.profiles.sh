#!/bin/bash

# TODO: automate build orders & list
profile_default()
{
 add_run_dep m4
 add_run_dep autoconf
 add_run_dep libffi
 add_run_dep ncurses
 add_run_dep libbsd
 add_run_dep expat
 add_run_dep readline
 add_run_dep sqlite3
 add_run_dep bison
 add_run_dep pcre
 add_run_dep zlib
 add_run_dep bzip2
 add_run_dep openssl
 add_run_dep apr
 add_run_dep aprutil
 add_run_dep libxml2
 add_run_dep httpd

 [ "$PHP_NEEDED" == "1" ] &&
 {
  add_run_dep php
  add_run_dep suhosin
 }

 add_run_dep python3
 add_run_dep mod_wsgi

 return $?
}

profile_redis()
{
 add_run_dep redis
 return $?
}

profile_python()
{
 add_run_dep libffi ncurses zlib bzip2 readline
 add_run_dep openssl sqlite3 expat libxml2
 add_run_dep python3
}

profile_uwsgi()
{
 add_run_dep libffi
 add_run_dep ncurses
 add_run_dep zlib
 add_run_dep bzip2
 add_run_dep readline
 add_run_dep openssl
 add_run_dep sqlite3
 add_run_dep expat
 add_run_dep libxml2
 add_run_dep python3
 add_run_dep uwsgi
 return $?
}

profile_postgres()
{
 add_run_dep libressl
 add_run_dep libxml2
 add_run_dep zlib
 add_run_dep ncurses
 add_run_dep readline
 add_run_dep postgresql
 return $?
}

profile_openvpn()
{
 add_run_dep openssl
 add_run_dep lzo
 #we don't want you "linuxpam"
 #add_run_dep linuxpam
 add_run_dep openvpn
 return $?
}

profile_gcc()
{
 add_build_dep m4
 add_run_dep zlib
 add_run_dep binutils
 add_run_dep gmp
 add_run_dep mpfr
 add_run_dep mpc
 add_run_dep gcc
 return $?
}

profile_varnish()
{
 # varnish needs python (">= 2.7") for generating some files
 # build time dependency only so these should not stay here...
 #
 add_run_dep libffi ncurses zlib bzip2 readline
 add_run_dep openssl sqlite3 expat libxml2
 add_run_dep python3

 # temporary workaround for missing backtrace() in musl
 [ -f "/etc/alpine-release" ] &&
 {
   apk add --no-cache libexecinfo-dev
 }

 add_run_dep pcre
 add_run_dep ncurses
 add_run_dep readline
 add_run_dep varnish

 return $?
}

profile_curl()
{
 add_run_dep openssl
 add_run_dep curl

 return $?
}

profile_haproxy()
{
 add_run_dep pcre
 add_run_dep zlib
 add_run_dep ncurses # needed by readline
 add_run_dep readline # required by lua
 add_run_dep openssl
 add_run_dep lua
 add_run_dep haproxy

 return $?
}

profile_git()
{
 add_build_dep m4
 add_build_dep autoconf
 add_run_dep zlib
 add_run_dep git

 return $?
}

### EOF ###
