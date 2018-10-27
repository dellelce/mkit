#
# Custom build for openssl
build_openssl()
{
 typeset id="openssl"
 export rc=0

 echo "Building $id [${BOLD}$(getbasename $id)${RESET}] at $(date)"
 echo

 typeset cwd="$PWD"
 cd $srcdir_openssl || return 1

 time_start

 echo "Configuring..."
 {
   logFile=$(logger_file ${id}_configure)
   ./config shared --prefix=$prefix --libdir=lib > ${logFile} 2>&1
   rc=$?
 }

 [ $rc -ne 0 ] && { cd "$cwd"; time_end; cat "${logFile}"; echo ; echo "Failed configure for OpenSSL";  return $rc; }

 echo "Running make..."
 {
   logFile=$(logger_file ${id}_make)
   make > ${logFile} 2>&1
   rc=$?
 }
 [ $rc -ne 0 ] && { cd "$cwd"; time_end; cat "${logFile}"; echo ; echo "Failed make for OpenSSL";  return $rc; }

 echo "Running make install..."
 {
   logFile=$(logger_file ${id}_install)
   make install > ${logFile} 2>&1
   rc=$?
 }

 [ $rc -ne 0 ] && { cd "$cwd"; time_end; cat "${logFile}"; echo ; echo "Failed make install for OpenSSL";  return $rc; }

 # no to disable manual generation: we delete ssl/man after the "build"
 [ -d "$prefix/ssl/man" ] && rm -rf "$prefix/ssl/man"

 time_end
 return 0
}
