#!/bin/bash

profile_gnubuild()
{
 add_build_dep perl
 add_build_dep makemaker
 add_build_dep datadumper
 add_build_dep m4
 add_build_dep autoconf
 add_build_dep automake
 add_build_dep libtool
}

profile_gnudev()
{
 add_run_dep perl
 add_run_dep makemaker
 add_run_dep datadumper
 add_run_dep m4
 add_run_dep autoconf
 add_run_dep automake
 add_run_dep libtool
}

# TODO: automate build orders & list
profile_default()
{
 profile_gnubuild
 profile_python
 add_build_dep bison
 add_run_dep expat
 add_run_dep pcre
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
 add_run_dep xz
 add_run_dep libffi ncurses zlib bzip2 readline
 add_run_dep openssl sqlite3 expat libxml2
 add_run_dep python3
}

profile_pythonbuild()
{
 add_build_dep xz
 add_build_dep libffi ncurses zlib bzip2 readline
 add_build_dep openssl sqlite3 expat libxml2
 add_build_dep python3
}

#python2
profile_python2()
{
 add_run_dep xz
 add_run_dep libffi ncurses zlib bzip2 readline
 add_run_dep openssl sqlite3 expat libxml2
 add_run_dep python2
}

profile_uwsgi()
{
 profile_python
 add_run_dep uwsgi
 return $?
}

profile_postgres()
{
# 170519 changing to openssl because:
# building with libressl fails with:
#postgresql/postgresql-11.3/src/backend/libpq/be-secure-openssl.c:1103:63: error: ‘Port’ has no member named ‘peer'’
#   strlcpy(ptr, X509_NAME_to_cstring(X509_get_subject_name(port->peer)), len);
 add_run_dep openssl
 add_run_dep libxml2
 add_run_dep zlib
 add_run_dep ncurses
 add_run_dep readline
 add_run_dep postgresql
 return $?
}

profile_postgres10()
{
 add_run_dep openssl
 add_run_dep libxml2
 add_run_dep zlib
 add_run_dep ncurses
 add_run_dep readline
 add_run_dep postgresql10
 return $?
}

profile_postgres11()
{
 add_run_dep openssl
 add_run_dep libxml2
 add_run_dep zlib
 add_run_dep ncurses
 add_run_dep readline
 add_run_dep postgresql11
 return $?
}

profile_timescaledb()
{
 add_build_dep cmake
 add_build_dep bison # only when building from commit/tag/branch (not "packaged" source)
 profile_postgres11
 add_run_dep timescaledb
 return $?
}

profile_openvpn()
{
 profile_gnudev
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

profile_gcc7()
{
 add_build_dep m4
 add_run_dep zlib
 add_run_dep binutils
 add_run_dep gmp
 add_run_dep mpfr
 add_run_dep mpc
 add_run_dep gcc7
 return $?
}

profile_gccgo7()
{
 add_build_dep m4
 add_run_dep zlib
 add_run_dep binutils
 add_run_dep gmp
 add_run_dep mpfr
 add_run_dep mpc
 add_options gcc7 go
 add_run_dep gcc7
 return $?
}

profile_gcc6()
{
 add_build_dep m4
 add_run_dep zlib
 add_run_dep binutils
 add_run_dep gmp
 add_run_dep mpfr
 add_run_dep mpc
 add_run_dep gcc6
 return $?
}

profile_varnish()
{
 # varnish needs python (">= 2.7") for generating some files
 # build time dependency only so these should not stay here...
 #
 profile_python
 profile_gnubuild

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
 profile_gnubuild
 add_run_dep zlib
 add_run_dep curl
 add_run_dep git

 return $?
}

profile_shared()
{
 profile_gnudev
 profile_python
 add_run_dep bison
}

profile_slcp()
{
 add_build_dep cmake
 add_run_dep libgit2
 add_run_dep slcp
}

profile_readline()
{
 add_run_dep readline
}

profile_bind()
{
 # libxml2 & openssl are included in python profile
 # mixing run-time and build-time dependencies is not supported at this time
 # *IF* this means need to link from multiple prefixes)
 profile_python
 add_run_dep bind
}

profile_cairo()
{
 #this will be needed when moving from alpine 3.8 to 3.9
 #add_build_dep pkgconfig
 add_run_dep zlib
 add_run_dep libpng
 add_run_dep freetype
 add_run_dep gperf
 add_run_dep expat
 #I thought uuid was not mandatory, temporarily re-disabling
 #add_run_dep fontconfig
 add_run_dep pixman
 add_run_dep cairo
}

profile_iftop()
{
 profile_gnubuild
 add_build_dep gettext
 add_build_dep flex
 add_run_dep libpcap
 add_run_dep ncurses
 add_run_dep iftop
}

profile_blender()
{
 add_build_dep cmake
 add_run_dep python # it needs python, but it could be a run-time dep only
 add_run_dep blender
}

profile_imagemagick()
{
 add_run_dep zlib
 add_run_dep libpng
 add_run_dep imagemagick
}

# standalone cmake
profile_cmake()
{
 add_run_dep cmake
}

profile_openscad()
{
 profile_opengl
 add_run_dep glew
 add_run_dep opencsg
 add_run_dep cgal
 add_run_dep openscad
}

profile_opengl()
{
 #gnubuild to be used with alpine 3.9 or should we just check for pkgconf(ig)
 #profile_gnubuild

 #xcbproto has some python code...
 profile_pythonbuild
 add_run_dep dri2proto
 add_run_dep glproto
 add_run_dep pciaccess
 add_run_dep libdrm
 add_run_dep xproto
 add_run_dep xextproto
 add_run_dep xtrans
 add_run_dep kbproto
 add_run_dep inputproto
 add_run_dep xcbproto
 add_run_dep pthreadstubs
 add_run_dep xau
 add_run_dep xcb
 add_run_dep x11
 add_run_dep damageproto
 add_run_dep fixesproto
 add_run_dep xfixes
 add_run_dep xdamage
 add_run_dep xext
 add_run_dep xf86vidmodeproto
 add_run_dep xxf86vm
 add_run_dep xorgmacros
 add_run_dep xshmfence
 add_run_dep randrproto
 add_run_dep renderproto
 add_run_dep libxrender
 add_run_dep libxrandr
 add_run_dep xrandr
 add_run_dep expat2_1
 add_run_dep zlib

 #travis: currently building mesa3d exceeds 10 minutes and travil kills the process because nothing is sent to stdout
 #        this is a bit "excessive" but we want to hog almost all processors available
 typeset cpucnt=$(egrep -c '^processor' /proc/cpuinfo)
 [ $cpucnt -eq 2 ] && add_make_options mesa3d -j${cpucnt}
 [ $cpucnt -gt 2 ] && { let cpucnt="(( $cpucnt - 1 ))";  add_make_options mesa3d -j${cpucnt}; }
 add_run_dep mesa3d
}

profile_libgit2()
{
 add_build_dep cmake
 #profile_python
 add_run_dep openssl
 add_run_dep libssh2
 add_run_dep libgit2
}

profile_mosquitto()
{
 add_build_dep cmake
 add_run_dep openssl
 add_run_dep mosquitto
}

profile_nettle()
{
 add_run_dep gmp
 add_run_dep nettle
}

profile_x11()
{
 add_run_dep dri2proto
 add_run_dep glproto
 add_run_dep pciaccess
 add_run_dep libdrm
 add_run_dep xproto
 add_run_dep xextproto
 add_run_dep xtrans
 add_run_dep kbproto
 add_run_dep inputproto
 add_run_dep xcbproto
 add_run_dep pthreadstubs
 add_run_dep xau
 add_run_dep xcb
 add_run_dep x11
 add_run_dep damageproto
 add_run_dep fixesproto
 add_run_dep xfixes
 add_run_dep xdamage
 add_run_dep xext
 add_run_dep xf86vidmodeproto
 add_run_dep xxf86vm
 add_run_dep xorgmacros
 add_run_dep xshmfence
 add_run_dep randrproto
 add_run_dep renderproto
 add_run_dep libxrender
 add_run_dep libxrandr
 add_run_dep xrandr
}

profile_libxc()
{
 add_run_dep libxc
}

profile_leptonica()
{
 add_run_dep libpng
 add_run_dep expat # required by freetype
 add_run_dep gperf # required by fontconfig
 add_run_dep freetype # required by fontconfig
 add_run_dep fontconfig
 add_run_dep leptonica
}

profile_inkscape()
{
 add_run_dep pango
 add_run_dep glib
 add_run_dep inkscape
}

### EOF ###
