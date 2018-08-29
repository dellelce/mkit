#!/bin/bash
#
# mkit functions library
#

### FUNCTIONS ###

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
 [ ! -d "$pkgbuilddir" ] &&
 {
  mkdir -p "$pkgbuilddir";
 } ||
 {
  pkgbuilddir="$BUILDDIR/${id}.${RANDOM}"; mkdir -p "$pkgbuilddir";
 }

 cd "$pkgbuilddir" ||
 {
  echo "build_perl: Failed to change to build directory: " $pkgbuilddir;
  return 1;
 }

 echo
 echo "Building Perl in $pkgbuilddir at $(date)"
 echo

 time_start

 echo "Configuring..."
 {
  $dir/Configure  -des                          \
                  -Dprefix="${prefix}"          \
                  -Dvendorprefix="${prefix}"    \
                  -Dman1dir=${prefix}/man/man1  \
                  -Dman3dir=${prefix}/man3      \
                  -Duseshrplib                  \
                  $* 2>&1
  rc_conf=$?
 } | build_logger "${id}_configure"

 [ "$rc_conf" -ne 0 ] && return $rc_conf

 echo "Running make..."
 {
  make 2>&1
  rc_make=$?
 } | build_logger ${id}_make

 [ "$rc_make" -ne 0 ] && return $rc_make

 echo "Running make install..."
 {
  make install 2>&1
  rc_makeinstall=$?
 } | build_logger ${id}_makeinstall

 cd "$WORKDIR"

 return $rc_makeinstall
}

#
# build_perl: wrapper to handle "standard" arguments and uncompression
build_perl()
{
 uncompress perl $fn_perl || { echo "Failed uncompress for: $fn_perl"; return 1; }
 build_perl_core perl $srcdir_perl
}

#
# sqlite3
#
build_sqlite3()
{
 uncompress sqlite3 $fn_sqlite3 || { echo "Failed uncompress for: $fn_sqlite3"; return 1; }
 build_gnuconf sqlite3 $srcdir_sqlite3
 return $?
}

# libbsd
#
build_libbsd()
{
 uncompress libbsd $fn_libbsd || { echo "Failed uncompress for: $fn_libbsd"; return 1; }
 build_gnuconf libbsd $srcdir_libbsd
 return $?
}

# libressl
#
build_libressl()
{
 uncompress libressl $fn_libressl || { echo "Failed uncompress for: $fn_libressl"; return 1; }
 build_gnuconf libressl $srcdir_libressl
 return $?
}

# postgresql
#
build_postgresql()
{
 uncompress postgresql $fn_postgresql || { echo "Failed uncompress for: $fn_postgresql"; return 1; }
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
 build_gnuconf postgresql $srcdir_postgresql
 return $?
}

#
# ncurses
#
build_ncurses()
{
 uncompress ncurses $fn_ncurses || { echo "Failed uncompress for: $fn_ncurses"; return 1; }
 build_gnuconf ncurses $srcdir_ncurses --with-shared --with-cxx-shared  \
                                       --without-ada
 return $?
}

#
build_libffi()
{
 typeset rc=0 dir=""

 uncompress libffi $fn_libffi || { echo "Failed uncompress for: $fn_libffi"; return 1; }
 build_gnuconf libffi $srcdir_libffi
 rc=$?
 [ $? -ne 0 ] && return $rc

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
  [ -f "$header" ] && ln -sf $header $prefix/include/$(basename $header)
 done

 return 0
}

#
# expat
build_expat()
{
 uncompress expat $fn_expat || { echo "Failed uncompress for: $fn_expat"; return 1; }
 build_gnuconf expat $srcdir_expat
 return $?
}

#
# M4 Macro Processor
build_m4()
{
 uncompress m4 $fn_m4 || { echo "Failed uncompress for: $fn_m4"; return 1; }
 build_gnuconf m4 $srcdir_m4
 return $?
}

#
# suhosin
#
# suhosin requires phpize to be run in source directory
#
build_suhosin()
{
 uncompress suhosin $fn_suhosin || { echo "Failed uncompress for: $fn_suhosin"; return 1; }
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
 uncompress apr $fn_apr || { echo "Failed uncompress for: $fn_apr"; return 1; }
 build_gnuconf apr $srcdir_apr
 return $?
}

#
# bison
#
build_bison()
{
 uncompress bison $fn_bison || { echo "Failed uncompress for: $fn_bison"; return 1; }
 build_gnuconf bison $srcdir_bison MAKEINFO=:
 return $?
}

#
# automake
#
build_automake()
{
 uncompress automake $fn_automake || { echo "Failed uncompress for: $fn_automake"; return 1; }
 build_gnuconf automake $srcdir_automake
 return $?
}

#
# readline
#
build_readline()
{
 uncompress readline $fn_readline || { echo "Failed uncompress for: $fn_readline"; return 1; }
 [ -f "/etc/alpine-release" -a -f "$srcdir_readline/shlib/Makefile.in" ] &&
 {
   rlmk="$srcdir_readline/shlib/Makefile.in"

   ls -lt $rlmk
   sed -i -e 's/SHLIB_LIBS = @SHLIB_LIBS@/SHLIB_LIBS = @SHLIB_LIBS@ -lncurses/' $rlmk
   ls -lt $rlmk

   echo "Debug: lib in install target"
   ls -lt "$prefix/lib"
 }

 build_gnuconf readline $srcdir_readline
 return $?
}

#
# autoconf
#
build_autoconf()
{
 uncompress autoconf $fn_autoconf || { echo "Failed uncompress for: $fn_autoconf"; return 1; }
 build_gnuconf autoconf $srcdir_autoconf
 return $?
}

#
# pcre
#
build_pcre()
{
 uncompress pcre $fn_pcre || { echo "Failed uncompress for: $fn_pcre"; return 1; }
 build_gnuconf pcre $srcdir_pcre # AUTOCONF=: AUTOHEADER=: AUTOMAKE=: ACLOCAL=:
 return $?
}

#
# APR-Util
#
build_aprutil()
{
 uncompress aprutil $fn_aprutil || { echo "Failed uncompress for: $fn_aprutil"; return 1; }
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
 uncompress mod_wsgi $fn_mod_wsgi || { echo "Failed uncompress for: $fn_mod_wsgi"; return 1; }
 opt="BADCONFIGURE" build_gnuconf mod_wsgi $srcdir_mod_wsgi \
                                       --with-apxs="${prefix}/bin/apxs" \
                                       --with-python="${prefix}/bin/python3"
 return $?
}

#
# Apache HTTPD
#
build_httpd()
{
 uncompress httpd $fn_httpd || { echo "Failed uncompress for: $fn_httpd"; return 1; }
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
 build_gnuconf httpd $srcdir_httpd \
                               --with-z="${prefix}"		\
                               --with-apr="${prefix}"		\
                               --with-apr-util="${prefix}"

 return $?
}

build_libxml2()
{
 uncompress libxml2 $fn_libxml2 || { echo "Failed uncompress for: $fn_libxml2"; return 1; }
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
 {
  dirList=$(find $dir -type d)
  fileList=$(find $dir -type f)

  #make directores
  for bad in $dirList
  do
   baseDir=${bad#${dir}/} #remove "base" directory
   mkdir -p "$baseDir" || return "$?"
  done

  # link files
  for bad in $fileList
  do
   baseFile=${bad#${dir}/} #remove "base" directory
   ln -sf "$bad" "$baseFile" || return "$?"
  done
 }

 echo
 echo "Building $id in $pkgbuilddir at $(date)"
 echo
 # make
 {
  logFile=$(logger_file ${id}_make)
  echo "Running make: logging at ${logFile}"

  cwd="$PWD"
  cd "$dir"

  make > ${logFile} 2>&1; rc_make="$?"

  cd "$cwd"
 }
 [ "$rc_make" -ne 0 ] && return "$rc_make"

 # make shared (not needed on cygwin?)
 {
  logFile=$(logger_file ${id}_makeso)
  echo "Running make shared: logging at ${logFile}"

  cwd="$PWD"
  cd "$dir"

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

  cwd="$PWD"
  cd "$dir"

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
 uncompress bzip2 $fn_bzip2 || { echo "Failed uncompress for: $fn_bzip2"; return 1; }
 build_bzip2_core bzip2 $srcdir_bzip2

 return $?
}

#
# zlib
# Needed by some python packages
#
build_zlib()
{
 uncompress zlib $fn_zlib || { echo "Failed uncompress for: $fn_zlib"; return 1; }

 # zlib's configure does not support building in a different directory than source
 opt="BADCONFIGURE" build_gnuconf zlib $srcdir_zlib

 return $?
}

#
# python3
#
build_python3()
{
 uncompress python3 $fn_python3 || { echo "Failed uncompress for: $fn_python3"; return 1; }
 LDFLAGS="-L${prefix}/lib -Wl,-rpath=${prefix}/lib"  \
 CFLAGS="-I${prefix}/include"                        \
 build_gnuconf python3 $srcdir_python3 \
            --with-openssl="${prefix}" \
            --enable-shared \
            --with-system-expat \
            --with-system-ffi   \
            --with-ensurepip=yes

 return $?
}

#
# php
#
build_php()
{
 uncompress php $fn_php || { echo "Failed uncompress for: $fn_php"; return 1; }
 build_gnuconf php $srcdir_php \
                 --enable-shared --with-libxml-dir=${prefix} \
                 --with-openssl=${prefix} --with-openssl-dir="${prefix}"     \
                 --with-apxs2="${prefix}/bin/apxs"
 return $?
}

#
# Custom build for openssl
#
build_openssl()
{
 typeset id="openssl"
 uncompress openssl $fn_openssl || { echo "Failed uncompress for: $fn_openssl"; return 1; }
 export rc=0

 echo
 echo Building OpenSSL
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
#
build_raw_core()
{
 typeset rc=0 cwd=""
 export rc_conf=0 rc_make=0 rc_makeinstall=0
 typeset id="$1"; shift   # build id
 typeset dir="$1"; shift  # src directory
 typeset pkgbuilddir="$BUILDDIR/$id"

 [ ! -d "$pkgbuilddir" ] &&
   { mkdir -p "$pkgbuilddir"; } ||
   { pkgbuilddir="$BUILDDIR/${id}.${RANDOM}"; mkdir -p "$pkgbuilddir"; }

 cd "$pkgbuilddir" ||
 {
  echo "build: Failed to change to build directory: " $pkgbuilddir;
  return 1;
 }

 # redis & many others does not have a GNU configure but just a raw makefile
 # or some other sometimes fancy buil systems.
 # we create a build directory different than source directory for them.
 {
  dirList=$(find $dir -type d)
  fileList=$(find $dir -type f)

  #make directores
  for bad in $dirList
  do
   baseDir=${bad#${dir}/} #remove "base" directory
   mkdir -p "$baseDir" || return "$?"
  done

  # link files
  for bad in $fileList
  do
   baseFile=${bad#${dir}/} #remove "base" directory
   ln -s "$bad" "$baseFile" || return "$?"
  done
 }

 echo
 echo "Building $id in $pkgbuilddir at $(date)"
 echo
 # make
 {
  logFile=$(logger_file ${id}_make)
  echo "Running make: logging at ${logFile}"

  cwd="$PWD"
  cd "$dir"

  make > ${logFile} 2>&1; rc_make="$?"

  cd "$cwd"
 }
 [ "$rc_make" -ne 0 ] && { cat ${logFile}; return "$rc_make"; }

 # make install
 {
  logFile=$(logger_file ${id}_makeinstall)
  echo "Running make install: logging at ${logFile}"

  cwd="$PWD"
  cd "$dir"

  make install PREFIX="${prefix}" > ${logFile} 2>&1
  rc_makeinstall="$?"

  cd "$cwd"
 }
 [ "$rc_makeinstall" -ne 0 ] && { cat "${logFile}"; return "$rc_makeinstall"; }

 return 0
}

#
# redis
build_redis()
{
 uncompress redis $fn_redis || { echo "Failed uncompress for: $fn_redis"; return 1; }
 build_raw_core redis $srcdir_redis

 return $?
}

#
#
build_uwsgi()
{
 typeset rc=0 dir=""

 uncompress uwsgi $fn_uwsgi || { echo "Failed uncompress for: $fn_uwsgi"; return 1; }

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

### EOF ###
