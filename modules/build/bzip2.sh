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

 time_stat

 echo "Building $id [${BOLD}$(getbasename $id)${RESET}] at $(date)"
 echo
 # make
 {
  logFile=$(logger_file ${id}_make)
  echo "Running make"

  cwd="$PWD"; cd "$dir"

  make > ${logFile} 2>&1; rc_make="$?"

  cd "$cwd"
 }
 [ "$rc_make" -ne 0 ] && return "$rc_make"

 # make shared (not needed on cygwin?)
 {
  logFile=$(logger_file ${id}_makeso)
  echo "Running make shared"

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
 time_end

 return 0
}

build_bzip2()
{
 build_bzip2_core bzip2 $srcdir_bzip2

 return $?
}
