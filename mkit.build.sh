#!/bin/bash
#
# mkit build library
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

 # print download map ==== do we really need to print this?
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

 # if there is any build-time dep prepare a custom prefix for them.
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
  func_rc=$?

  [ $func_rc -ne 0 ] &&
  {
    # module was not found built-in: try as module
    module_func="$MKIT/modules/build/${pkg}.sh"

    [ -f "$module_func" ] &&
    {
      . "$module_func"
      type $func >/dev/null 2>&1
      func_rc=$?
    } ||
    {
      echo "Build function for $pkg is invalid or does not exist"
      return 1
    }
  }

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
