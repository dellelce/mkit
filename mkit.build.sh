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

# logger_file: return a full file name to be used for the specified id
logger_file()
{
 typeset logid="$1"
 typeset LAST_LOG="${LOGSDIR}/${TIMESTAMP}_${logid}.log"

 echo $LAST_LOG
}

# Perform sanity checks and try to generate GNU configure if possible
build_sanity_gnuconf()
{
 typeset acpath=""
 [ -z "$1" ] && { echo "build_sanity_gnuconf srcdirectory"; return 1; }
 [ ! -d "$1" ] && { echo "build_sanity_gnuconf: invalid srcdirectory: $1"; return 1; }

 type aclocal >/dev/null 2>&1  &&
 {
  acpath=$(aclocal --print-ac-dir)
  export ACLOCAL_PATH="${acpath}"

  [ -d "${prefix}/share/aclocal" -a "${acpath}" != "${prefix}/share/aclocal" ] &&
  {
   export ACLOCAL_PATH="${prefix}/share/aclocal:$ACLOCAL_PATH"
  }

  [ -d "/usr/share/aclocal" -a "${acpath}" != "/usr/share/aclocal" ] &&
  {
   export ACLOCAL_PATH="$ACLOCAL_PATH:/usr/share/aclocal"
  }
 } ||
 {
  echo "INFO: aclocal not found: can be an issue for some GNU configure builds"
 }

 # try autogen.sh
 [ ! -e "$1/configure" -a -e "$1/configure.ac" -a -e "$1/autogen.sh" ] &&
 {
  typeset cwd="$PWD"
  cd "$1"

  NOCONFIGURE=1 \
  ./autogen.sh 2>&1; typeset ar_rc=$?
  cd "$cwd"
  [ $ar_rc -ne 0 ] && { echo "autogen.sh failed with rc = $ar_rc"; return $ar_rc; }
  build_sanity_gnuconf $1
  return $?
 }

 # try autoreconf
 [ ! -e "$1/configure" -a -e "$1/configure.ac" ] &&
 {
  typeset cwd="$PWD"
  cd "$1"

  autoreconf -vif 2>&1; ar_rc=$?
  cd "$cwd"
  [ $ar_rc -ne 0 ] && { echo "autoreconf failed with rc = $ar_rc"; return $ar_rc; }
  build_sanity_gnuconf $1
  return $?
 }

 # check again and use buildconf.sh this time
 [ ! -e "$1/configure" -a -e "$1/buildconf.sh" ] &&
 {
  echo "build_sanity_gnuconf: no configure file in: $1 but buildconf.sh is present"
  $dir/buildconf.sh; typeset bc_rc=$?
  [ $bc_rc -ne 0 ] && return $bc_rc
  build_sanity_gnuconf $dir
  return $?
 }

 # give up if stil missing.
 [ ! -f "$1/configure" ] && { echo "build_sanity_gnuconf: no configure file in: $1"; return 1; }

 return 0
}

#
# logging function to be used by build functions
build_logger()
{
 export LAST_LOG=$(logger_file "$1")
 cat >> "${LAST_LOG}"
}

# GNU Configure wrapper with layers to generate "configure" file if needed
#
build_gnuconf()
{
 typeset rc=0
 export rc_conf=0 rc_make=0 rc_makeinstall=0
 typeset id="$1"; shift   # build id
 typeset dir="$1"; shift  # src directory
 typeset pkgbuilddir="$BUILDDIR/$id"

 [ -z "$dir" ] && { echo "usage: build_gnuconf id source_dir_path"; return 1; }

 [ ! -d "$pkgbuilddir" ] &&
   { mkdir -p "$pkgbuilddir"; } ||
   { pkgbuilddir="$BUILDDIR/${id}.${RANDOM}"; mkdir -p "$pkgbuilddir"; }

 cd "$pkgbuilddir" ||
 {
  echo "build_gnuconf: Failed to change to build directory: " $pkgbuilddir;
  return 1;
 }

 echo "Building $id [${BOLD}$(getbasename $id)${RESET}] at $(date)"
 echo

 time_start # setup timer

 logFile=$(logger_file ${id}_sanity)
 build_sanity_gnuconf $dir > ${logFile} 2>&1; rc=$?

 [ $rc -ne 0 ] && { cat "${logFile}"; echo "build_gnuconf: build sanity tests failed for $dir"; return $rc; }

 # some "configure"s do not support building in a directory different than the source directory
 # TODO: cwd to "$dir"
 [ "$opt" == "BADCONFIGURE" ] &&
 {
  prepare_build "$dir"
 }

 export CFLAGS="${BASE_CFLAGS} -I${prefix}/include"
 export CPPFLAGS="${BASE_CFLAGS} -I${prefix}/include"
 export LDFLAGS="${BASE_LDFLAGS} -L${prefix}/lib -Wl,-rpath=${prefix}/lib"

 echo "Configuring..."
 logFile=$(logger_file ${id}_configure)
 $dir/configure --prefix="${prefix}" $* > ${logFile} 2>&1; rc_conf=$?

 [ "$rc_conf" -ne 0 ] && { cat "${logFile}"; return $rc_conf; }

 echo "Running make..."
 logFile=$(logger_file ${id}_make)
 eval make_options="\$make_options_${pkg}"
 make $make_options > ${logFile} 2>&1; rc_make="$?"
 unset make_options

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
#    BASE_CFLAGS
#    BASE_CPPFLAGS
#    BASE_LDFLAGS
#    all variables set by add_options if any
run_build()
{
 typeset pkg=""
 typeset rc=0
 typeset buildprefix=""
 typeset mainprefix="$prefix"

 [ ! -z "$CFLAGS" ] && { export BASE_CFLAGS="$CFLAGS"; unset CFLAGS; }
 [ ! -z "$CPPFLAGS" ] && { export BASE_CPPFLAGS="$CPPFLAGS"; unset CPPFLAGS; }
 [ ! -z "$LDFLAGS" ] && { export BASE_LDFLAGS="$CFLAGS"; unset LDFLAGS; }

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
   mkdir -p "$buildprefix/lib"
   ln -s "$buildprefix/lib" "$buildprefix/lib64"
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

 # Main Build Loop!
 for pkg in $BUILDTIME_LIST $RUNTIME_LIST
 do
  build=0
  [ ${pkg} != "${pkg#_}" ] && { build=1; pkg="${pkg#_}"; }

  [ "$build" -eq 0 ] && { prefix="$mainprefix"; } || { prefix="$buildprefix"; }

  echo "Build type is $build: Prefix for $pkg is: $prefix"

  fname=$(getbasename $pkg)
  [ "$fname" == "installed" ] && continue

  eval options="\$options_${pkg}" # load options for specified package

  echo

  # TODO: add discovery/fall-back function
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

  # check build state: do we really need to build?
  # This is to be used when re-running a failed build and want to skip some components
  have_hook global need_to_build && hook global need_to_build ${pkg} || continue

  do_uncompress ${pkg} || return $?

  [ "$build" -eq 1 ] &&
  {
    #typeset mainprefix="$prefix"
    prefix="$buildprefix" $func $options; rc=$?
    #prefix="$mainprefix"  #BUG: TODO: this shouldn't be needed
  } ||
  {
    # Launch Build
    $func $options; rc=$?
  }

  [ "$rc" -ne 0 ] &&
  {
    echo "Failed build of $pkg with return code: $rc"
    return $rc
  }

  # run "successful_built" hook for run-time dependencies
  [ "$build" -eq 1 ] && continue
  have_hook global successful_built && hook global successful_built ${pkg} || break
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

 #export CFLAGS="${BASE_CFLAGS} -I${prefix}/include"
 #export CPPFLAGS="${BASE_CPPLAGS} -I${prefix}/include"
 #export LDFLAGS="${BASE_LDFLAGS} -L${prefix}/lib -Wl,-rpath=${prefix}/lib"

 # make
 logFile=$(logger_file ${id}_make)
 echo "Running make"
 cwd="$PWD"; cd "$dir"

 eval make_options="\$make_options_${pkg}"
 make $make_options > ${logFile} 2>&1; rc_make="$?"
 unset make_options

 cd "$cwd"
 [ "$rc_make" -ne 0 ] && { cat ${logFile}; return "$rc_make"; }

 # make install
 logFile=$(logger_file ${id}_makeinstall)
 echo "Running make install"

 cwd="$PWD"; cd "$dir"

 eval install_options="\$install_options_${pkg}"
 make install PREFIX="${prefix}" > ${logFile} 2>&1; rc_makeinstall="$?"
 unset install_options

 cd "$cwd"
 [ "$rc_makeinstall" -ne 0 ] && { cat "${logFile}"; return "$rc_makeinstall"; }

 time_end
 return 0
}

build_raw_lite()
{
 typeset rc=0 cwd=""
 export rc_conf=0 rc_make=0 rc_makeinstall=0
 typeset id="$1"; shift   # build id
 typeset pkgbuilddir="$BUILDDIR/$id"
 typeset makedir=""

 [ ! -d "$pkgbuilddir" ] &&
 { mkdir -p "$pkgbuilddir"; } ||
 { pkgbuilddir="$BUILDDIR/${id}.${RANDOM}"; mkdir -p "$pkgbuilddir"; }

 echo "Building $id [${BOLD}$(getbasename $id)${RESET}] at $(date)"
 echo
 time_start

 have_hook $id configure &&
 {
  logFile=$(logger_file ${id}_configure)
  cwd="$PWD"
  echo "Configuring..."

  hook $id configure > ${logFile} 2>&1; rc_conf="$?"

  cd "$cwd"
 }
 [ "$rc_conf" -ne 0 ] && { cat ${logFile}; return "$rc_conf"; }

 # where is the Makefile?
 # if the previous step run successfully we could find it in the build directory
 # otherwise it is in the source directory.... if both fail we give up
 for makedir in $pkgbuilddir $dir
 do
  [ -f "$makedir/Makefile" ] && break
 done

 [ -z "$makedir" ] && { echo "Failed to find a Makefile."; return 1; }

 # make
 {
  logFile=$(logger_file ${id}_make)
  echo "Running make"

  cwd="$PWD"; cd "$makedir"

  make > ${logFile} 2>&1; rc_make="$?"

  cd "$cwd"
 }
 [ "$rc_make" -ne 0 ] && { cat ${logFile}; return "$rc_make"; }

 # make install
 {
  logFile=$(logger_file ${id}_makeinstall)
  echo "Running make install"

  cwd="$PWD"; cd "$makedir"

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

 # many do not have GNU configure just a raw makefile
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

 PERL5LIB="$prefix/share/perl5" \
 make install > ${logFile} 2>&1
 rc_makeinstall="$?"

 cd "$cwd"
 [ "$rc_makeinstall" -ne 0 ] && { cat "${logFile}"; return "$rc_makeinstall"; }

 time_end
 return 0
}

# add_options: allow to pass custom options from profiles to build functions
add_options()
{
 typeset pkg="$1"; shift
 typeset options="$*"

 eval "export options_${pkg}=\"${options}\""
}

# add_make_options: allow to pass custom options from profiles to "make" step
add_make_options()
{
 typeset pkg="$1"; shift
 typeset options="$*"

 eval "export make_options_${pkg}=\"${options}\""
}

# add_install_options: allow to pass custom options from profiles to "make install" step
add_install_options()
{
 typeset pkg="$1"; shift
 typeset options="$*"

 eval "export install_options_${pkg}=\"${options}\""
}

### EOF ###
