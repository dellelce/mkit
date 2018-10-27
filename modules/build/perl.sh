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
 [ ! -d "$pkgbuilddir" ] && { mkdir -p "$pkgbuilddir"; } ||
 {
  pkgbuilddir="$BUILDDIR/${id}.${RANDOM}"; mkdir -p "$pkgbuilddir";
 }

 cd "$pkgbuilddir" ||
 {
  echo "build_perl: Failed to change to build directory: " $pkgbuilddir;
  return 1;
 }

 # redis & many others does not have a GNU configure but just a raw makefile
 # or some other sometimes fancy buil systems.
 # we create a build directory different than source directory for them.
 prepare_build $dir

 echo "Building $id [${BOLD}$(getbasename $id)${RESET}] at $(date)"
 echo

 time_start

 echo "Configuring..."
 logFile=$(logger_file ${id}_conf)

 $dir/Configure  -des                          \
                 -Dprefix="${prefix}"          \
                 -Dvendorprefix="${prefix}"    \
                 -Dman1dir=${prefix}/man/man1  \
                 -Dman3dir=${prefix}/man3      \
                 -Duseshrplib                  \
                 $* > ${logFile} 2>&1
 rc_conf=$?
 [ "$rc_conf" -ne 0 ] && { cat "${logFile}";  return $rc_conf; }

 echo "Running make..."

 logFile=$(logger_file ${id}_make)
 make > ${logFile} 2>&1
 rc_make=$?
 [ "$rc_make" -ne 0 ] && { cat "${logFile}"; return $rc_make; }

 echo "Running make install..."

 logFile=$(logger_file ${id}_makeinstall)
 make install > ${logFile} 2>&1
 rc_makeinstall=$?
 [ "$rc_makeinstall" -ne 0 ] && { cat "${logFile}"; }

 cd "$WORKDIR"
 return $rc_makeinstall
}

#
# build_perl: wrapper to handle "standard" arguments and uncompression
build_perl()
{
 build_perl_core perl $srcdir_perl
}
