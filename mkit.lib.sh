#!/bin/bash
#
# mkit core library
#

# prepare_build: only for those that do not support explicitly a build directory
#                different than source
# This function expects to be in the build directory
prepare_build()
{
 typeset dir="$1"
 [ ! -d "$dir" ] && return 1

 dirList=$(find $dir -type d)

 #make directores
 for bad in $dirList
 do
  baseDir=${bad#${dir}/} #remove "base" directory
  mkdir -p "$baseDir" || return "$?"
 done

 # link files
 find $dir -type f | awk -vdir=$dir '
  {
   fn=$0
   bad=$0
   sub(dir"/", "", fn);
   printf("ln -sf %c%s%c %c%s%c\n", 34, bad, 34, 34, fn, 34)
  }
 ' | $SHELL
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
 rm -f srcget
 ln -s srcget-${srcget} srcget
 export PATH="$PWD/srcget:$PATH"
}

# wrapper to srcget.sh, for now
get_source()
{
 srcget.sh -n $*
}

# download
#
# Used Globals:
#   DOWNLOADS
#   DOWNLOAD_MAP
#   RUNTIME_LIST
#   BUILDTIME_LIST
download()
{
 typeset pkg fn
 typeset wd="$PWD"
 export DOWNLOAD_MAP=""

 cd "$DOWNLOADS" || return $?

 for pkg in $RUNTIME_LIST
 do
  fn=$(get_source $pkg)
  srcget_rc=$?
  fn="$PWD/$fn"
  [ ! -f "$fn" ] && { echo "Failed downloading $pkg: rc = $srcget_rc"; return $srcget_rc; }
  echo "${BOLD}$pkg${RESET} has been downloaded as: " $fn

  DOWNLOAD_MAP="${DOWNLOAD_MAP} ${pkg}:${fn}"  # this will fail if ${fn} has spaces!

  # save directory to a variable named after the package
  eval "fn_${pkg}=$fn"
 done

 # build-time packages need only be downloaded if not already installed
 for pkg in $BUILDTIME_LIST
 do
  hook $pkg is_installed &&
  {
   INSTALLED_LIST="$INSTALLED_LIST $pkg";
   eval "fn_${pkg}=installed"
   echo "${BOLD}$pkg${RESET} is a build-time dependency and is already installed."
   continue
  }

  fn=$(get_source $pkg)
  srcget_rc=$?
  fn="$PWD/$fn"
  [ ! -f "$fn" ] && { echo "Failed downloading $pkg: rc = $srcget_rc"; return $srcget_rc; }
  echo "${BOLD}$pkg${RESET} has been downloaded as: " $fn

  DOWNLOAD_MAP="${DOWNLOAD_MAP} ${pkg}:${fn}"  # this will fail if ${fn} has spaces!

  # save directory to a variable named after the package
  eval "fn_${pkg}=$fn"
 done

 cd "$wd"
}

# get filename for given package
#
getfilename()
{
 typeset pkg="$1"; [ -z "$pkg" ] && return 1

 eval echo "\$fn_${pkg}"
}

# get base filename for given package
#
getbasename()
{
 typeset pkg="$1"; [ -z "$pkg" ] && return 1

 eval basename "\$fn_${pkg}"
}

# xz handler
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
# bz2 handler
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

 [ -d "$dir" ] && { eval "export srcdir_${id}=${dir}"; return 0; }

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

 [ ! -f "$1/configure" -a -f "$1/configure.ac" ] &&
 {
  typeset cwd="$PWD"
  cd "$1"
  autoreconf -vif >/dev/null 2>&1; ar_rc=$?
  cd "$cwd"
  [ $ar_rc -ne 0 ] && { echo "autoreconf failed with rc = $ar_rc"; return $ar_rc; }
  build_sanity_gnuconf $1
  return $?
 }

 [ ! -f "$1/configure" -a -f "$1/buildconf.sh" ] &&
 {
  echo "build_sanity_gnuconf: no configure file in: $1 but buildconf.sh is present"
  $dir/buildconf.sh; bc_rc=$?
  [ $bc_rc -ne 0 ] && return $bc_rc
  build_sanity_gnuconf $dir
  return $?
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

 [ -z "$dir" ] && { echo "usage: build_gnuconf id source_dir_path"; return 1; }
 build_sanity_gnuconf $dir
 rc=$?

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
  prepare_build "$dir"
 }

 echo "Building $id [${BOLD}$(getbasename $id)${RESET}] at $(date)"
 echo

 time_start # setup timer

 [ -z "$CFLAGS" ] && export CFLAGS="-I${prefix}/include"
 [ -z "$LDFLAGS" ] && export LDFLAGS="-L${prefix}/lib -Wl,-rpath=${prefix}/lib"

 echo "Configuring..."
 logFile=$(logger_file ${id}_configure)
 $dir/configure --prefix="${prefix}" $* > ${logFile} 2>&1; rc_conf=$?

 [ "$rc_conf" -ne 0 ] && { cat "${logFile}"; return $rc_conf; }

 echo "Running make..."
 logFile=$(logger_file ${id}_make)
 make > ${logFile} 2>&1; rc_make=$?

 [ "$rc_make" -ne 0 ] && { cat "${logFile}"; return $rc_make; }

 echo "Running make install..."
 logFile=$(logger_file ${id}_makeinstall)
 make install > ${logFile} 2>&1; rc_makeinstall=$?

 cd "$WORKDIR"

 [ "$rc_makeinstall" -ne 0 ] && { cat "${logFile}"; }
 time_end

 return $rc_makeinstall
}

# add_run_dep: runtime dependencies
#
add_run_dep()
{
 typeset id_list="$*" item=""

 [ -z "$id_list" ] && return 1 # sanitycheck
 [ -z "$RUNTIME_LIST" ] && { export RUNTIME_LIST="$id_list"; } || { export RUNTIME_LIST="$RUNTIME_LIST $id_list"; }

 # remove possible duplicates
 RUNTIME_LIST=$(
   for item in $RUNTIME_LIST
   do
     echo $item
   done | awk '!x[$0]++'
)
}

# add_build_dep: buildtime dependencies
#
add_build_dep()
{
 typeset id_list="$*" item=""

 [ -z "$id_list" ] && return 1 # sanitycheck
 [ -z "$BUILDTIME_LIST" ] && { export BUILDTIME_LIST="$id_list"; } || { export BUILDTIME_LIST="$BUILDTIME_LIST $id_list"; }

 # remove possible duplicates
 BUILDTIME_LIST=$(
   for item in $BUILDTIME_LIST
   do
     echo $item
   done | awk '!x[$0]++'
)
}

# generic wrapper for uncompress
# TODO: these two functions may be merged?
do_uncompress ()
{
 typeset id=$1;
 eval  "fn=\$fn_$id";
 uncompress $id $fn || { echo "Failed uncompress for: $fn_$id"; return 1; }
 return $?
}

#
# run_build: build all
# globals used:
#    RUNTIME_LIST
#    BUILDTIME_LIST
#    DOWNLOAD_MAP
run_build()
{
 typeset pkg=""
 typeset rc=0
 typeset buildprefix=""

 # the next function (download) uses the variable SRCLIST to determine
 # which packages to download
 # download latest archives / builds name mapping
 download || { echo "Download failed for one of the components"; exit 1; }

 [ ! -z "$DOWNLOAD_MAP" ] &&
 {
  echo "Downloaded software:"
  echo
  for item in $DOWNLOAD_MAP
  do
   echo $item| awk -F: '
   {
    cnt=split($2,bn_a,"/");
    bn=bn_a[cnt]
    printf("%-12s %s\n", $1, bn);
   }
'
  done
 }

 [ ! -z "$BUILDTIME_LIST" ] &&
 {
   export buildprefix="$TMP/build_prefix_${RANDOM}${RANDOM}"

   # no checks?
   mkdir -p "$buildprefix/bin"
   # build prefix files to be found before everything else
   export PATH="$buildprefix/bin:$PATH"

   # use underscore to mark package as "build-dep" (to simplify following loop)
   BUILDTIME_LIST=$(
   for _pkg in $BUILDTIME_LIST
   do
     echo "_"${_pkg}
   done
   )
 }

 for pkg in $BUILDTIME_LIST $RUNTIME_LIST
 do
  build=0
  [ ${pkg} != "${pkg#_}" ] && { build=1; pkg="${pkg#_}"; }

  fname=$(getbasename $pkg)
  [ "$fname" == "installed" ] && continue

  echo

  func="build_${pkg}"

  type $func >/dev/null 2>&1
  [ $? -ne 0 ] && { echo "Build function for $pkg is invalid or does not exist"; return 1; }

  # uncompress
  do_uncompress ${pkg} || return $?

  [ "$build" -eq 1 ] &&
  {
    prefix="$buildprefix" $func; rc=$?
  } ||
  {
    $func; rc=$?
  }

  [ "$rc" -ne 0 ] &&
  {
    [ -d "$buildprefix" ] && rm -rf "$buildprefix"
    echo "Failed build of $pkg with return code: $rc"
    return $rc
  }
 done

 [ -d "$buildprefix" ] && rm -rf "$buildprefix"
 return 0 # we hate bash bugs so we add a return 0 here
}

#
# timing functions
#
time_start()
{
 export start=$(date +%s)
}

time_end()
{
 export end=$(date +%s)

 let  elapsed="(( $end - $start ))"
 echo "Elapsed: ${elapsed}secs"
}

# autotools/automake require recent perl
test_perl_automake()
{
 eval $(getPerlVersions)

 [ "$PERL_REVISION" -eq 5 -a "$PERL_VERSION" -lt 10 ] &&
 {
  add_build_dep perl
  export PERL_NEEDED=1
  cat << EOF
   Detected version of perl is ${PERL_REVISION}.${PERL_VERSION}.${PERL_SUBVERSION} minimum required version is 5.10.
   Will download and build local version.

EOF
 }
}

#
# hooks!
hook()
{
 # package name, hook name, arguments

 typeset pname="$1"; shift
 typeset hname="$1"; shift
 typeset args="$*"; shift

 typeset hookfile="$MKIT/hooks/$pname/${hname}.sh"

 [ -f "$hookfile" ] &&
 {
  $SHELL "$hookfile" $args
  return $?
 }

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

 # we create a build directory different than source directory for them.
 prepare_build "$dir"

 echo "Building $id [${BOLD}$(getbasename $id)${RESET}] at $(date)"
 echo
 time_start
 # make
 {
  logFile=$(logger_file ${id}_make)
  echo "Running make: logging at ${logFile}"

  cwd="$PWD"; cd "$dir"

  make > ${logFile} 2>&1; rc_make="$?"

  cd "$cwd"
 }
 [ "$rc_make" -ne 0 ] && { cat ${logFile}; return "$rc_make"; }

 # make install
 {
  logFile=$(logger_file ${id}_makeinstall)
  echo "Running make install: logging at ${logFile}"

  cwd="$PWD"; cd "$dir"

  make install PREFIX="${prefix}" > ${logFile} 2>&1
  rc_makeinstall="$?"

  cd "$cwd"
 }
 [ "$rc_makeinstall" -ne 0 ] && { cat "${logFile}"; return "$rc_makeinstall"; }

 time_end
 return 0
}

#
#
build_perlmodule()
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
 prepare_build "$dir"

 echo "Building $id [${BOLD}$(getbasename $id)${RESET}] at $(date)"
 echo
 time_start
 # configurepl
 logFile=$(logger_file ${id}_configurepl)
 echo "Running Makefile.PL"

 cwd="$PWD"; cd "$dir"

 PERL5LIB=$prefix/share/perl5 \
 $prefix/bin/perl Makefile.PL PREFIX=$prefix > ${logFile} 2>&1; rc_configurepl="$?"

 cd "$cwd"

 [ "$rc_configurepl" -ne 0 ] && { cat ${logFile}; return "$rc_configurepl"; }

 # make
 logFile=$(logger_file ${id}_make)
 echo "Running make"

 cwd="$PWD"; cd "$dir"

 PERL5LIB=$prefix/share/perl5 \
 make > ${logFile} 2>&1; rc_make="$?"

 cd "$cwd"
 [ "$rc_make" -ne 0 ] && { cat ${logFile}; return "$rc_make"; }

 # make install
 logFile=$(logger_file ${id}_makeinstall)
 echo "Running make install"

 cwd="$PWD"; cd "$dir"

 PERL5LIB=$prefix/share/perl5 \
 make install > ${logFile} 2>&1
 rc_makeinstall="$?"

 cd "$cwd"
 [ "$rc_makeinstall" -ne 0 ] && { cat "${logFile}"; return "$rc_makeinstall"; }

 time_end
 return 0
}

### EOF ###
