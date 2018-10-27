#!/bin/bash
#
# mkit components library
#

# get perl versions as variables
getPerlVersions()
{
 typeset perlBin="perl"

 ${perlBin} -V | awk '
FNR == 1 \
{
 gsub(/[()]/, " ");

 cnt = split($0, a);
 last = "" # state variable

 for(idx in a)
 {
  item = a[idx]

  if (item == "revision" || item == "version" || item == "subversion")
  {
   last = item
   continue
  }

  if (last == "revision")   { revision = item;   last = ""; continue; }
  if (last == "version")    { version = item;    last = ""; continue; }
  if (last == "subversion") { subversion = item; last = ""; continue; }
 }
}

END \
{
  printf("export PERL_REVISION=\"%s\";",   revision);
  printf("export PERL_VERSION=\"%s\";",    version);
  printf("export PERL_SUBVERSION=\"%s\";", subversion);
}
'
#Summary of my perl5  revision 5 version 22 subversion 2  configuration:
}

#
# Build perl - custom function only for perl
build_perl_core()
{
 typeset rc=0
 export rc_conf=0 rc_make=0 rc_makeinstall=0
 typeset id="$1";  shift  # build id
 typeset dir="$1"; shift  # src directory
 typeset pkgbuilddir="$BUILDDIR/$id"

 # No Sanity checks!

 # Other steps
 [ ! -d "$pkgbuilddir" ] && { mkdir -p "$pkgbuilddir"; } ||
 {
  pkgbuilddir="$BUILDDIR/${id}.${RANDOM}"; mkdir -p "$pkgbuilddir";
 }

 cd "$pkgbuilddir" ||
 {
  echo "build_perl: Failed to change to build directory: " $pkgbuilddir;
  return 1;
 }

 # redis & many others does not have a GNU configure but just a raw makefile
 # or some other sometimes fancy buil systems.
 # we create a build directory different than source directory for them.
 prepare_build $dir

 echo "Building $id [${BOLD}$(getbasename $id)${RESET}] at $(date)"
 echo

 time_start

 echo "Configuring..."
 logFile=$(logger_file ${id}_conf)

 $dir/Configure  -des                          \
                 -Dprefix="${prefix}"          \
                 -Dvendorprefix="${prefix}"    \
                 -Dman1dir=${prefix}/man/man1  \
                 -Dman3dir=${prefix}/man3      \
                 -Duseshrplib                  \
                 $* > ${logFile} 2>&1
 rc_conf=$?
 [ "$rc_conf" -ne 0 ] && { cat "${logFile}";  return $rc_conf; }

 echo "Running make..."

 logFile=$(logger_file ${id}_make)
 make > ${logFile} 2>&1
 rc_make=$?
 [ "$rc_make" -ne 0 ] && { cat "${logFile}"; return $rc_make; }

 echo "Running make install..."

 logFile=$(logger_file ${id}_makeinstall)
 make install > ${logFile} 2>&1
 rc_makeinstall=$?
 [ "$rc_makeinstall" -ne 0 ] && { cat "${logFile}"; }

 cd "$WORKDIR"
 return $rc_makeinstall
}

#
# build_perl: wrapper to handle "standard" arguments and uncompression
build_perl()
{
 build_perl_core perl $srcdir_perl
}

# sqlite3
build_sqlite3()
{
 build_gnuconf sqlite3 $srcdir_sqlite3
 return $?
}

# git
build_git()
{
 opt="BADCONFIGURE" \
 build_gnuconf git $srcdir_git \
          --with-zlib="${prefix}"
 return $?
}

# openvpn
#
build_openvpn()
{
 enable_plugin_auth_pam=no build_gnuconf openvpn $srcdir_openvpn
 return $?
}

# lzo
#
build_lzo()
{
 build_gnuconf lzo $srcdir_lzo
 return $?
}

# linux-pam
#
build_linuxpam()
{
 build_gnuconf linuxpam $srcdir_linuxpam --disable-nls --disable-db
 return $?
}

# libbsd
#
build_libbsd()
{
 build_gnuconf libbsd $srcdir_libbsd
 return $?
}

# libressl
#
build_libressl()
{
 build_gnuconf libressl $srcdir_libressl
 return $?
}

# postgresql
#
build_postgresql()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
 build_gnuconf postgresql $srcdir_postgresql
 return $?
}

#
# ncurses
#
build_ncurses()
{
 build_gnuconf ncurses $srcdir_ncurses --with-shared --with-cxx-shared  \
                                       --without-ada
 return $?
}

#
build_libffi()
{
 typeset rc=0 dir=""

 build_gnuconf libffi $srcdir_libffi
 rc=$?
 [ $rc -ne 0 ] && return $rc

 # libffi ignores --libdir and --includedir options of configure
 # installs includes in $prefix/lib/libffi-version/include/ etc
 # installs all other files in $prefix/lib64
 # the lib64 path is *NOT* detectd by python while include is (pkg-config?)
 # leaving commented includes copy as a "temporary" note
 #
 [ -d "$prefix/lib64" ] && mv $prefix/lib64/* $prefix/lib/

 mkdir -p "$prefix/include" # make sure target directory exists
 for header in $prefix/lib/libffi-*/include/*
 do
  [ -f "$header" ] && ln -sf "$header" "$prefix/include/$(basename $header)"
 done

 return 0
}

#
# expat
build_expat()
{
 build_gnuconf expat $srcdir_expat
 return $?
}

#
# M4 Macro Processor
build_m4()
{
 build_gnuconf m4 $srcdir_m4
 return $?
}

# suhosin: phpize required to be run in source directory
#
build_suhosin()
{
 {
  echo "Running phpize in $srcdir_suhosin"
  cwd="$PWD"
  cd $srcdir_suhosin
  phpize
  cd "$cwd"
 }
 build_gnuconf suhosin $srcdir_suhosin
 return $?
}

#
# apr
#
build_apr()
{
 build_gnuconf apr $srcdir_apr
 return $?
}

#
# bison
#
build_bison()
{
 build_gnuconf bison $srcdir_bison MAKEINFO=:
 return $?
}

#
# automake
#
build_automake()
{
 build_gnuconf automake $srcdir_automake
 return $?
}

#
# readline
#
build_readline()
{
 [ -f "/etc/alpine-release" -a -f "$srcdir_readline/shlib/Makefile.in" ] &&
 {
   rlmk="$srcdir_readline/shlib/Makefile.in"

   ls -lt $rlmk
   sed -i -e 's/SHLIB_LIBS = @SHLIB_LIBS@/SHLIB_LIBS = @SHLIB_LIBS@ -lncurses/' $rlmk
   ls -lt $rlmk

   # commenting until a proper option for debugging is added
   #echo "Debug: lib in install target"
   #ls -lt "$prefix/lib"
 }

 build_gnuconf readline $srcdir_readline
 return $?
}

# GNU autoconf
#
build_autoconf()
{
 build_gnuconf autoconf $srcdir_autoconf
 return $?
}

# GNU libtool
#
build_libtool()
{
 build_gnuconf libtool $srcdir_libtool
 return $?
}

#
# pcre
#
build_pcre()
{
 build_gnuconf pcre $srcdir_pcre # AUTOCONF=: AUTOHEADER=: AUTOMAKE=: ACLOCAL=:
 return $?
}

#
# APR-Util
#
build_aprutil()
{
 # both crypto/openssl & sqlite3 do not appear to work (link) with the following options.... ignoring for now
 #build_gnuconf aprutil $srcdir_aprutil --with-apr="${prefix}" \
 #                   --with-openssl="${prefix}" --with-crypto \
 #                    --with-sqlite3="${prefix}" \
 #                  --with-apr="${prefix}" # --with-openssl="${prefix}" --with-crypto
 build_gnuconf aprutil $srcdir_aprutil \
                       --with-apr="${prefix}"
 return $?
}

#
# mod_wsgi
build_mod_wsgi()
{
 opt="BADCONFIGURE" \
 build_gnuconf mod_wsgi $srcdir_mod_wsgi \
                        --with-apxs="${prefix}/bin/apxs" \
                        --with-python="${prefix}/bin/python3"
 return $?
}

#
# Apache HTTPD
#
build_httpd()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
 build_gnuconf httpd $srcdir_httpd \
                     --with-z="${prefix}"		\
                     --with-apr="${prefix}"		\
                     --with-apr-util="${prefix}"

 return $?
}

build_libxml2()
{
 build_gnuconf libxml2 $srcdir_libxml2 --without-python

 return $?
}

#
# bzip2
#
build_bzip2_core()
{
 typeset rc=0 cwd=""
 export rc_conf=0 rc_make=0 rc_makeso=0 rc_makeinstall=0
 typeset id="$1"; shift   # build id
 typeset dir="$1"; shift  # src directory
 typeset pkgbuilddir="$BUILDDIR/$id"

 [ ! -d "$pkgbuilddir" ] &&
   { mkdir -p "$pkgbuilddir"; } ||
   { pkgbuilddir="$BUILDDIR/${id}.${RANDOM}"; mkdir -p "$pkgbuilddir"; }

 cd "$pkgbuilddir" ||
 {
  echo "build_gzip2_core: Failed to change to build directory: " $pkgbuilddir;
  return 1;
 }

 #bzip2 does not have a configure but just a raw makefile
 prepare_build

 echo "Building $id [${BOLD}$(getbasename $id)${RESET}] at $(date)"
 echo
 # make
 {
  logFile=$(logger_file ${id}_make)
  echo "Running make: logging at ${logFile}"

  cwd="$PWD"; cd "$dir"

  make > ${logFile} 2>&1; rc_make="$?"

  cd "$cwd"
 }
 [ "$rc_make" -ne 0 ] && return "$rc_make"

 # make shared (not needed on cygwin?)
 {
  logFile=$(logger_file ${id}_makeso)
  echo "Running make shared: logging at ${logFile}"

  cwd="$PWD"; cd "$dir"

  make clean # the next step will not rebuild and the "linker" will fail without this
  make -f Makefile-libbz2_so  > ${logFile} 2>&1
  rc_makeso="$?"

  cd "$cwd"
 }
 [ "$rc_makeso" -ne 0 ] && return "$rc_make"

 # make install
 {
  logFile=$(logger_file ${id}_makeinstall)
  echo "Running make install: logging at ${logFile}"

  cwd="$PWD"; cd "$dir"

  make install PREFIX="${prefix}" > ${logFile} 2>&1
  cp "libbz2.so.1.0.6" "${prefix}/lib"
  ln -sf "${prefix}/lib/libbz2.so.1.0.6" "${prefix}/lib/libbz2.so.1.0"
  rc_makeinstall="$?"

  cd "$cwd"
 }
 [ "$rc_makeinstall" -ne 0 ] && return "$rc_makeinstall"

 return 0
}

build_bzip2()
{
 build_bzip2_core bzip2 $srcdir_bzip2

 return $?
}

lua_platform()
{
 typeset platform=$(uname -s| awk -F_ ' { print tolower($1); } ')

 [ "$platform" == "cygwin" ] && platform="mingw"

 echo $platform
}

#
# Build lua
build_lua_core()
{
 typeset rc=0
 export rc_conf=0 rc_make=0 rc_makeinstall=0
 typeset id="$1";  shift  # build id
 typeset dir="$1"; shift  # src directory
 typeset pkgbuilddir="$BUILDDIR/$id"

 # No Sanity checks!

 # Other steps
 [ ! -d "$pkgbuilddir" ] && { mkdir -p "$pkgbuilddir"; } ||
 {
  pkgbuilddir="$BUILDDIR/${id}.${RANDOM}"; mkdir -p "$pkgbuilddir";
 }

 cd "$pkgbuilddir" ||
 {
  echo "build_lua: Failed to change to build directory: " $pkgbuilddir;
  return 1;
 }

 prepare_build $dir

 echo "Building $id [${BOLD}$(getbasename $id)${RESET}] at $(date)"
 echo

 time_start

 # no configure step for lua
 #build_logger "${id}_configure"
 #[ "$rc_conf" -ne 0 ] && return $rc_conf

 logFile=$(logger_file ${id}_make)
 echo "Running make..."
 {
  conf="$(lua_platform) INSTALL_TOP=${prefix}"
  conf="${conf} MYCFLAGS=-I${prefix}/include MYLDFLAGS=-L${prefix}/lib"
  conf="${conf} MYLIBS=-lncurses"
  echo "Configuration: $conf"
  make $conf 2>&1
  rc_make=$?
 } > ${logFile}
 [ $rc_make -ne 0 ] && { cd "$cwd"; time_end; cat "${logFile}"; echo ; echo "Failed make for ${id}";  return $rc_make; }

 echo "Running make install..."
 logFile=$(logger_file ${id}_makeinstall)
 {
  make install INSTALL_TOP=${prefix} 2>&1
  rc_makeinstall=$?
 } > ${logFile}

 cd "$WORKDIR"
 [ $rc_makeinstall -ne 0 ] && { cat "${logFile}"; echo ; echo "Failed make install for ${id}"; }

 time_end
 return $rc_makeinstall
}

# build_lua: wrapper to handle "standard" arguments and uncompression
build_lua()
{
 build_lua_core lua $srcdir_lua
}

#
# Build haproxy
build_haproxy_core()
{
 typeset rc=0
 export rc_conf=0 rc_make=0 rc_makeinstall=0
 typeset id="$1";  shift  # build id
 typeset dir="$1"; shift  # src directory
 typeset pkgbuilddir="$BUILDDIR/$id"

 # No Sanity checks!

 # Other steps
 [ ! -d "$pkgbuilddir" ] && { mkdir -p "$pkgbuilddir"; } ||
 {
  pkgbuilddir="$BUILDDIR/${id}.${RANDOM}"; mkdir -p "$pkgbuilddir";
 }

 cd "$pkgbuilddir" ||
 {
  echo "build_haproxy: Failed to change to build directory: " $pkgbuilddir;
  return 1;
 }

 prepare_build "$dir"

 echo "Building $id [${BOLD}$(getbasename $id)${RESET}] at $(date)"
 echo

 time_start

 logFile=$(logger_file ${id}_make)
 echo "Running make..."
 {
  #TODO: add SLZ
  conf="TARGET=linux2628"
  conf="${conf} LDFLAGS=-Wl,-rpath=${prefix}/lib" \
  conf="${conf} PREFIX=${prefix}"
  conf="${conf} LUA_LIB=${prefix}/lib"
  conf="${conf} LUA_INC=${prefix}/include"
  conf="${conf} ZLIB_LIB=${prefix}/lib"
  conf="${conf} ZLIB_INC=${prefix}/include"
  conf="${conf} SSL_LIB=${prefix}/lib"
  conf="${conf} SSL_INC=${prefix}/include"
  conf="${conf} PCREDIR=${prefix}"
  conf="${conf} USE_PCRE=1"
  conf="${conf} USE_OPENSSL=1"
  conf="${conf} USE_ZLIB=1"
  conf="${conf} USE_LUA=1"
  conf="${conf} USE_NS=1"
  echo "Configuration: $conf"
  make $conf 2>&1
  rc_make=$?
 } > ${logFile}
 [ $rc_make -ne 0 ] && { cd "$cwd"; time_end; cat "${logFile}"; echo ; echo "Failed make for ${id}";  return $rc_make; }

 echo "Running make install..."
 logFile=$(logger_file ${id}_makeinstall)
 {
  make install PREFIX=${prefix} 2>&1
  rc_makeinstall=$?
 } > ${logFile}

 cd "$WORKDIR"
 [ $rc_makeinstall -ne 0 ] && { cat "${logFile}"; echo ; echo "Failed make install for ${id}"; }

 time_end
 return $rc_makeinstall
}

# build_haproxy: wrapper to handle "standard" arguments and uncompression
build_haproxy()
{
 build_haproxy_core haproxy $srcdir_haproxy
 return $?
}

# zlib
#
build_zlib()
{
 # zlib's configure does not support building in a different directory than source
 opt="BADCONFIGURE" \
 build_gnuconf zlib $srcdir_zlib

 return $?
}

# python3
#
build_python3()
{
 typeset rc=0
 typeset fn

 LDFLAGS="-L${prefix}/lib -Wl,-rpath=${prefix}/lib"  \
 CFLAGS="-I${prefix}/include"                        \
 build_gnuconf python3 $srcdir_python3 \
            --with-openssl="${prefix}" \
            --enable-shared \
            --with-system-expat \
            --with-system-ffi   \
            --with-ensurepip=yes
 rc=$?

 # remove this file until I have proof I need it ;)
 # is it for building modules? Not clear in Makefile's "libainstall" target
 for fn in $prefix/lib/python*/config-*/lib*.a
 do
   [ -f "$fn" ] && rm -f "$fn"
 done

 return $rc
}

# php
#
build_php()
{
 build_gnuconf php $srcdir_php \
                 --enable-shared \
                 --with-libxml-dir=${prefix} \
                 --with-openssl=${prefix} \
                 --with-openssl-dir="${prefix}"     \
                 --with-apxs2="${prefix}/bin/apxs"
 return $?
}

#
build_binutils()
{
 build_gnuconf binutils $srcdir_binutils MAKEINFO=:
 return $?
}

build_gmp()
{
 build_gnuconf gmp $srcdir_gmp
 return $?
}

build_mpfr()
{
 build_gnuconf mpfr $srcdir_mpfr
 return $?
}

build_mpc()
{
 build_gnuconf mpc $srcdir_mpc
 return $?
}

build_gcc()
{
 MAKEINFO=: \
 build_gnuconf gcc $srcdir_gcc \
                   --enable-languages=c \
                   --with-gmp=${prefix}
                   --with-mpfr=${prefix}
                   --with-mpc=${prefix} \
                   --disable-multilib \
                   --disable-lto \
                   --with-system-zlib \
                   --disable-libstdcxx \
                   --disable-nls
 return $?
}

build_varnish()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"

 RST2MAN=: SPHINX=: \
 build_gnuconf varnish $srcdir_varnish
 return $?
}

build_curl()
{
 build_gnuconf curl $srcdir_curl
 return $?
}

#
# Custom build for openssl
build_openssl()
{
 typeset id="openssl"
 export rc=0

 echo "Building $id [${BOLD}$(getbasename $id)${RESET}] at $(date)"
 echo

 typeset cwd="$PWD"
 cd $srcdir_openssl || return 1

 time_start

 echo "Configuring..."
 {
   logFile=$(logger_file ${id}_configure)
   ./config shared --prefix=$prefix --libdir=lib > ${logFile} 2>&1
   rc=$?
 }

 [ $rc -ne 0 ] && { cd "$cwd"; time_end; cat "${logFile}"; echo ; echo "Failed configure for OpenSSL";  return $rc; }

 echo "Running make..."
 {
   logFile=$(logger_file ${id}_make)
   make > ${logFile} 2>&1
   rc=$?
 }
 [ $rc -ne 0 ] && { cd "$cwd"; time_end; cat "${logFile}"; echo ; echo "Failed make for OpenSSL";  return $rc; }

 echo "Running make install..."
 {
   logFile=$(logger_file ${id}_install)
   make install > ${logFile} 2>&1
   rc=$?
 }

 [ $rc -ne 0 ] && { cd "$cwd"; time_end; cat "${logFile}"; echo ; echo "Failed make install for OpenSSL";  return $rc; }

 # no to disable manual generation: we delete ssl/man after the "build"
 [ -d "$prefix/ssl/man" ] && rm -rf "$prefix/ssl/man"

 time_end
 return 0
}

#
# redis
build_redis()
{
 build_raw_core redis $srcdir_redis

 return $?
}

#
#
build_uwsgi()
{
 typeset rc=0 dir=""

 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"

 # we kindly ask you to use our preferred version of python
 sed -i -e 's/python$/python3/' ${srcdir_uwsgi}/Makefile

 # a proper makefile has always a "make install"...
 {
 cat << EOF

install:
	@cp uwsgi ${prefix}/bin
	@ls -lt ${prefix}/bin/uwsgi

EOF
 } >> "${srcdir_uwsgi}"/Makefile

 CPUCOUNT=1 \
 PYTHON=$prefix/bin/python3 \
 PROFILE="default" \
 build_raw_core uwsgi $srcdir_uwsgi

 return $?
}

#
build_datadumper()
{
 build_perlmodule datadumper $srcdir_datadumper
 return $?
}

build_makemaker()
{
 build_perlmodule makemaker $srcdir_makemaker
 return $?
}

### EOF ###
