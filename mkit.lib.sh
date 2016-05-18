#!/bin/bash
#
# mkit functions library
#


### FUNCTIONS ###

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
# downloaded
#
download()
{
 typeset pkg

 for pkg in $SRCLIST
 do
   fn=$(srcget.sh -n $pkg)
   fn="$PWD/$fn"
   [ ! -f "$fn" ] && { echo "Failed downloading $pkg"; return 1; }
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
 [ ! -d "$1" -o ! -f "$1/configure" ] && { echo "build_sanity_gnuconf: invalid srcdirectory"; return 1; }

 return 0
}

build_logger()
{
 typeset logid="$1"

 cat >> "${LOGSDIR}/${TIMESTAMP}_${logid}.log"
}

#
# Build  functions need to be executed from build directory
#
# all build here use GNU Configure
#

build_gnuconf()
{
 typeset rc=0 rc_conf=0 rc_make=0 rc_makeinstall=0
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
   { echo "build_gnuconf: Failed to change to build directory: " $pkgbuilddir; return 1; } 

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

build_aprutil()
{
 uncompress aprutil $fn_aprutil || { echo "Failed uncompress for: $fn_aprutil"; return 1; }
 build_gnuconf aprutil $srcdir_aprutil --with-apr="${prefix}"
 return $?
}

build_httpd()
{
 uncompress httpd $fn_httpd || { echo "Failed uncompress for: $fn_httpd"; return 1; }
 build_gnuconf httpd $srcdir_httpd --with-apr="${prefix}" --with-apr-util="${prefix}"
 return $?
}

build_libxml2()
{
 uncompress libxml2 $fn_libxml2 || { echo "Failed uncompress for: $fn_libxml2"; return 1; }
 build_gnuconf libxml2 $srcdir_libxml2 --without-python
 return $?
}

build_php()
{
 uncompress php $fn_php || { echo "Failed uncompress for: $fn_php"; return 1; }
 build_gnuconf php $srcdir_php --enable-shared --with-libxml-dir=${prefix} \
                 --with-openssl=${prefix} --with-openssl-dir="${prefix}"     \
                 --with-apxs2="${prefix}/bin/apxs"
 return $?
}

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
