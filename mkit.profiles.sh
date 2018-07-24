#!/bin/bash

# TODO: automate build orders & list
profile_default()
{
 add_build libffi
 add_build libbsd
 add_build libexpat
 add_build readline
 add_build sqlite3
 add_build m4
 add_build autoconf
 add_build bison
 add_build pcre
 add_build zlib
 add_build bzip2

 [ "$PERL_NEEDED" == "1" ] &&
 {
  add_build perl
 }

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
}

### EOF ###
