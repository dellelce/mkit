#!/bin/bash
#
# mkit core library
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

 type ${perlBin} 2>/dev/null && return $?

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
# Used Globals:
#   SRCLIST
#   DOWNLOADS
#
download()
{
 typeset pkg fn
 export DOWNLOAD_MAP=""

 for pkg in $SRCLIST
 do
  pushdir "$DOWNLOADS"
  fn=$(srcget.sh -n $pkg)
  srcget_rc=$?
  fn="$PWD/$fn"
  [ ! -f "$fn" ] && { echo "Failed downloading $pkg: rc = $srcget_rc"; return $srcget_rc; }
  echo "${BOLD}$pkg${RESET} has been downloaded as: " $fn

  DOWNLOAD_MAP="${DOWNLOAD_MAP} ${pkg}:${fn}"  # this will fail if ${fn} has spaces!

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
un_xz()
{
 typeset fn="$1" rc=0 dir=""; shift
 typeset bdir="$1"

 [ ! -f "$fn" ] && { echo "uncompress: $fn is not a file."; return 1; }

 xz -dc < "${fn}" | tar xf - -C "${bdir}"
 rc=$?
 [ "$rc" -eq 0 ] &&
 {
  dir=$(ls -d1t ${bdir}/* | head -1)
  [ -d "$dir" ] && echo $dir
  return 0
 }

 echo "un_xz return code: $rc"
 return $rc
}

#
# bz2
#
un_bz2()
{
 typeset fn="$1" rc=0 dir=""; shift
 typeset bdir="$*"

 [ ! -f "$fn" ] && return 1

 tar xjf  "${fn}" -C "${bdir}"
 rc=$?
 [ "$rc" -eq 0 ] &&
 {
  dir=$(ls -d1t ${bdir}/* | head -1)
  [ -d "$dir" ] && echo $dir
  return 0
 }

 echo "un_bz2 return code: $rc"
 return $rc
}

#
# gz
#
un_gz()
{
 typeset fn="$1" rc=0 dir=""; shift
 typeset bdir="$*"

 [ ! -f "$fn" ] && return 1

 tar xzf "${fn}" -C "${bdir}"
 rc=$?
 [ "$rc" -eq 0 ] && { dir=$(ls -d1t ${bdir}/* | head -1); [ -d "$dir" ] && echo $dir; return 0; }

 echo "un_gz return code: $rc"
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
 echo "$id: uncompressing ${BOLD}$(basename $fn)${RESET}"

 [ "$fn" != "${fn%.xz}" ] && { dir=$(un_xz "${fn}" "${bdir}"); save_srcdir $id $dir; return $?; }
 [ "$fn" != "${fn%.bz2}" ] && { dir=$(un_bz2 "${fn}" "${bdir}"); save_srcdir $id $dir; return $?; }
 [ "$fn" != "${fn%.tgz}" ] && { dir=$(un_gz "${fn}" "${bdir}"); save_srcdir $id $dir; return $?; }
 [ "$fn" != "${fn%.gz}" ] && { dir=$(un_gz "${fn}" "${bdir}"); save_srcdir $id $dir; return $?; }

 echo "uncompress: Can't handle $fn type"
 return 1
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

### BEGIN OF BUILD FUNCTIONS ###

#
#
build_sanity_gnuconf()
{
 [ -z "$1" ] && { echo "build_sanity_gnuconf srcdirectory"; return 1; }
 [ ! -d "$1" ] && { echo "build_sanity_gnuconf: invalid srcdirectory: $1"; return 1; }
 [ ! -f "$1/configure" -a -f "$1/buildconf.sh" ] &&
  {
   echo "build_sanity_gnuconf: no configure file in: $1 but buildconf.sh is present"
   return 2
  }
 [ ! -f "$1/configure" ] && { echo "build_sanity_gnuconf: no configure file in: $1"; return 1; }

 return 0
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

 # rc=2: buildconf.sh was found without configure: try run buildconf.sh and check again
 [ $rc -eq 2 ] && { $dir/buildconf.sh; bc_rc=$?; build_sanity_gnuconf $dir; rc=$?; }
 [ $rc -ne 0 ] && { echo "build_gnuconf: build sanity tests failed for $dir"; return $rc; }

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
 echo "Building $id at $(date)"
 echo

 [ -z "$CFLAGS" ] && export CFLAGS="-I${prefix}/include"
 [ -z "$LDFLAGS" ] && export LDFLAGS="-L${prefix}/lib -Wl,-rpath=${prefix}/lib"

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

#
# add_build
#
add_build()
{
 while [ ! -z "$1" ]
 do
  export BUILDLIST="$BUILDLIST $1"
  shift
 done
}

#
# run_build: build all "packages" in BUILDLIST
#
run_build()
{
 typeset pkg=""
 typeset rc=$?

 for pkg in $BUILDLIST
 do
   func="build_${pkg}"
   type $func >/dev/null 2>&1 # we expect $func to be..... a function!! everything else will fail
   [ $? -ne 0 ] && { echo "Build function for $pkg is invalid or does not exist"; return 1; }
   $func
   rc=$?

   [ "$rc" -ne 0 ] &&
   {
     echo "Failed build $pkg with return code: $rc"
     return $rc
   }
 done
}

### EOF ###
