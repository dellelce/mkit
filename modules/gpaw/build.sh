build_gpaw()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig";

 build_gpaw_core gpaw $srcdir_gpaw

 return $?
}

#
# Build gpaw
build_gpaw_core()
{
 export rc_pipinstall=0
 typeset id="$1";  shift  # build id
 typeset dir="$1"; shift  # src directory
 typeset pkgbuilddir="$BUILDDIR/$id"

 # Other steps
 [ ! -d "$pkgbuilddir" ] && { mkdir -p "$pkgbuilddir"; } ||
 {
   pkgbuilddir="$BUILDDIR/${id}.${RANDOM}"; mkdir -p "$pkgbuilddir";
 }

 cd "$pkgbuilddir" ||
 {
   echo "build_gpaw: Failed to change to build directory: " $pkgbuilddir;
   return 1;
 }

 prepare_build $dir

 echo "Building $id [${BOLD}$(getbasename $id)${RESET}] at $(date)"
 echo

 time_start

 logFile=$(logger_file ${id}_make)
 echo "Running pip install..."
 {
   LDFLAGS="-L${prefix}/lib -L/usr/lib -Wl,-rpath=${prefix}/lib -Wl,-rpath=/usr/lib"  \
   CFLAGS="-I${prefix}/include"       \
   pip3 install .
   rc_pipinstall=$?
 } > ${logFile} 2>&1
 [ $rc_pipinstall -ne 0 ] && { cd "$cwd"; time_end; cat "${logFile}"; echo ; echo "Failed pip install for ${id}";  return $rc_make; }

 cd "$WORKDIR"

 time_end
 return $rc_pipinstall
}
