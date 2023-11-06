#
# Build haproxy
build_haproxy_core()
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
  [ -f "/etc/alpine-release" ] &&
  {
    conf="TARGET=linux-musl"
  } ||
  {
    conf="TARGET=linux-glibc"
  }
  conf="${conf} LDFLAGS=-Wl,-rpath=${prefix}/lib" \
  conf="${conf} PREFIX=${prefix}"
  conf="${conf} LUA_LIB=${prefix}/lib"
  conf="${conf} LUA_INC=${prefix}/include"
  conf="${conf} ZLIB_LIB=${prefix}/lib"
  conf="${conf} ZLIB_INC=${prefix}/include"
  conf="${conf} SSL_LIB=${prefix}/lib"
  conf="${conf} SSL_INC=${prefix}/include"
  conf="${conf} PCRE2DIR=${prefix}"
  conf="${conf} USE_PCRE2_JIT=1"
  conf="${conf} USE_PCRE2=1"
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
