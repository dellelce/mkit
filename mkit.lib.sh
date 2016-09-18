#!/bin/bash
#
# mkit functions library
#

### FUNCTIONS ###

# Wrapping bash's popd/pushd for "portability"
pushdir()
{
 pushd "$1" > /dev/null
 return "$?"
}

popdir()
{
 popd > /dev/null
 return "$?"
}

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

# download srcget
get_srcget()
{
 wget -q -O ${srcget}.tar.gz               \
            "${srcgetUrl}/${srcget}.tar.gz" || return 1

 tar xzf ${srcget}.tar.gz  || return 2
 ln -sf srcget-${srcget} srcget
 export PATH="$PWD/srcget:$PATH"
}

#
# download
#
download()
{
 typeset pkg

 for pkg in $SRCLIST
 do
   pushdir "$DOWNLOADS"
   fn=$(srcget.sh -n $pkg)
   srcget_rc=$?
   fn="$PWD/$fn"
   [ ! -f "$fn" ] && { echo "Failed downloading $pkg: rc = $srcget_rc"; return $srcget_rc; }
   echo $pkg " has been downloaded as: " $fn

   # save directory to a variable named after the package
   eval "fn_${pkg}=$fn"
   popdir
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
 typeset fn="$1" rc=0 dir=""; shift
 typeset bdir="$1"

 [ ! -f "$fn" ] && { echo "uncompress: $fn is not a file."; return 1; }

 xz -dc < "${fn}" | tar xf - -C "${bdir}"
 rc=$?
 [ "$rc" -eq 0 ] && { dir=$(ls -d1t ${bdir}/* | head -1); [ -d "$dir" ] && echo $dir; return 0; }

 echo "uncompress_xz return code: $rc"
 return $rc
}

#
# bz2
#
uncompress_bz2()
{
 typeset fn="$1" rc=0 dir=""; shift
 typeset bdir="$*"

 [ ! -f "$fn" ] && return 1

 tar xjf  "${fn}" -C "${bdir}"
 rc=$?
 [ "$rc" -eq 0 ] && { dir=$(ls -d1t ${bdir}/* | head -1); [ -d "$dir" ] && echo $dir; return 0; }

 echo "uncompress_bz2 return code: $rc"
 return $rc
}

#
# gz
#
uncompress_gz()
{
 typeset fn="$1" rc=0 dir=""; shift
 typeset bdir="$*"

 [ ! -f "$fn" ] && return 1

 tar xzf "${fn}" -C "${bdir}"
 rc=$?
 [ "$rc" -eq 0 ] && { dir=$(ls -d1t ${bdir}/* | head -1); [ -d "$dir" ] && echo $dir; return 0; }

 echo "uncompress_gz return code: $rc"
 return $rc
}

#
#

save_srcdir()
{
 typeset id="$1"
 typeset dir="$2"

 [ -d "$dir" ] && { eval "srcdir_${id}=${dir}"; return 0; }

 echo "save_srcdir: $dir is not a directory."
 return 1
}

#
#
uncompress()
{
 typeset id="$1"
 typeset fn="$2"
 typeset bdir="${SRCDIR}/${id}"

 [ ! -f "$fn" ] && { echo "Invalid file name: $fn"; return 1; }
 mkdir -p "$bdir"

 echo
 echo "$id: uncompressing $fn"

 [ "$fn" != "${fn%.xz}" ] && { dir=$(uncompress_xz "${fn}" "${bdir}"); save_srcdir $id $dir; return $?; }
 [ "$fn" != "${fn%.bz2}" ] && { dir=$(uncompress_bz2 "${fn}" "${bdir}"); save_srcdir $id $dir; return $?; }
 [ "$fn" != "${fn%.gz}" ] && { dir=$(uncompress_gz "${fn}" "${bdir}"); save_srcdir $id $dir; return $?; }

 echo "uncompress: Can't handle $fn type"
 return 1
}

#
#
build_sanity_gnuconf()
{
 [ -z "$1" ] && { echo "build_sanity_gnuconf srcdirectory"; return 1; } 
 [ ! -d "$1" ] && { echo "build_sanity_gnuconf: invalid srcdirectory: $1"; return 1; }
 [ ! -f "$1/configure" ] && { echo "build_sanity_gnuconf: no configure file in: $1"; return 1; }

 return 0
}

#
# logger_file: return a full file name to be used for the specified id
#
logger_file()
{
 typeset logid="$1"
 typeset LAST_LOG="${LOGSDIR}/${TIMESTAMP}_${logid}.log"

 echo $LAST_LOG
}

#
# logging function to be used by build functions
#
build_logger()
{
 export LAST_LOG=$(logger_file "$1")
 cat >> "${LAST_LOG}"
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
# Build  functions need to be executed from build directory
#
# all build here use GNU Configure
#
build_gnuconf()
{
 typeset rc=0
 export rc_conf=0 rc_make=0 rc_makeinstall=0
 typeset id="$1"; shift   # build id
 typeset dir="$1"; shift  # src directory
 typeset pkgbuilddir="$BUILDDIR/$id"

 build_sanity_gnuconf $dir
 rc=$? 
 [ $rc -ne 0 ] &&  { echo "build_gnuconf: build sanity tests failed for $dir"; return $rc; }

 [ ! -d "$pkgbuilddir" ] && 
   { mkdir -p "$pkgbuilddir"; } ||
   { pkgbuilddir="$BUILDDIR/${id}.${RANDOM}"; mkdir -p "$pkgbuilddir"; }

 cd "$pkgbuilddir" ||
 {
  echo "build_gnuconf: Failed to change to build directory: " $pkgbuilddir;
  return 1;
 } 

 # some "configure"s do not supporting building in a directory different than the source directory
 # TODO: cwd to "$dir"

 [ "$opt" == "BADCONFIGURE" ] &&
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

 echo "Configuring..."
 {
  $dir/configure --prefix="${prefix}" $* 2>&1
  rc_conf=$?
 } | build_logger ${id}_configure

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

### 
build_sqlite3()
{
 uncompress sqlite3 $fn_sqlite3 || { echo "Failed uncompress for: $fn_sqlite3"; return 1; }
 build_gnuconf sqlite3 $srcdir_sqlite3
 return $?
}

build_m4()
{
 uncompress m4 $fn_m4 || { echo "Failed uncompress for: $fn_m4"; return 1; }
 build_gnuconf m4 $srcdir_m4
 return $?
}

build_autoconf()
{
 uncompress autoconf $fn_autoconf || { echo "Failed uncompress for: $fn_autoconf"; return 1; }
 build_gnuconf autoconf $srcdir_autoconf
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
#
build_apr()
{
 uncompress apr $fn_apr || { echo "Failed uncompress for: $fn_apr"; return 1; }
 build_gnuconf apr $srcdir_apr
 return $?
}
#

#
build_bison()
{
 uncompress bison $fn_bison || { echo "Failed uncompress for: $fn_bison"; return 1; }
 build_gnuconf bison $srcdir_bison MAKEINFO=:
 return $?
}

#
#
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
 #build_gnuconf aprutil $srcdir_aprutil --with-apr="${prefix}" --with-openssl="${prefix}" --with-crypto 
 #                     --with-sqlite3="${prefix}" --with-apr="${prefix}" # --with-openssl="${prefix}" --with-crypto 
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
   ln -s "$bad" "$baseFile" || return "$?"
  done
 }

 #
 echo
 echo "Building $id in $pkgbuilddir at $(date)"
 echo
 # make
 {
  logFile=$(logger_file ${id}_make)
  echo "Running make: logging at ${logFile}"
  cwd="$PWD"
  cd "$dir"
  make > ${logFile} 2>&1 
  rc_make="$?"
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
  ln -s "${prefix}/lib/libbz2.so.1.0.6" "${prefix}/lib/libbz2.so.1.0"
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
 export LDFLAGS="-L${prefix}/lib -Wl,-rpath=${prefix}/lib"
 build_gnuconf python3 $srcdir_python3 --enable-shared 

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
 uncompress openssl $fn_openssl || { echo "Failed uncompress for: $fn_openssl"; return 1; }
 export rc=0
 
 (
   echo
   echo Building OpenSSL
   echo

   cd $srcdir_openssl || return 1

   echo "Configuring..."
   {
     ./config shared --prefix=$prefix 2>&1
     rc=$?
   } | build_logger openssl_configure

   [ $rc -eq 0 ]  || { echo ; echo "Failed configure for OpenSSL";  return 1; } 

   echo "Running make..."
   {
     make 2>&1
     rc=$?
   } | build_logger openssl_make

   [ $rc -eq 0 ]  || { echo ; echo "Failed make for OpenSSL";  return 1; } 

   echo "Running make install..."
   {
     make install 2>&1
     rc=$?
   } | build_logger openssl_makeinstall

   [ $rc -eq 0 ]  || { echo ; echo "Failed make install for OpenSSL";  return 1; } 
 ) 
}

### EOF ###
