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
