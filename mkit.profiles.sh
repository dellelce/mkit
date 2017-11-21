#!/bin/bash

profile_default()
{
 build_libbsd || exit $?
 build_libexpat  || exit $?
 
 build_readline || exit $?

 build_sqlite3 || exit $?

 build_m4 || exit $?

 build_autoconf || exit $?

 build_bison || exit $?

 build_pcre || exit $?

 build_zlib || exit $?
 
 build_bzip2 || exit $?

 [ ! -z "$PERL_NEEDED" -a "$PERL_NEEDED" -eq 1 ] &&
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

 [ ! -z "$PHP_NEEDED" -a "$PHP_NEEDED" == 1 ] &&
 {
  build_php || exit $?
 
  build_suhosin || exit $?
 }

 build_python3 || exit $?

 build_mod_wsgi || exit $?
}


### EOF ###
