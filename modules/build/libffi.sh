#
build_libffi()
{
 typeset rc=0 dir=""

 build_gnuconf libffi $srcdir_libffi
 rc=$?
 [ $rc -ne 0 ] && return $rc

 # libffi ignores --libdir and --includedir options of configure
 # installs includes in $prefix/lib/libffi-version/include/ etc
 # installs all other files in $prefix/lib64
 # the lib64 path is *NOT* detectd by python while include is (pkg-config?)
 # leaving commented includes copy as a "temporary" note
 #
 [ -d "$prefix/lib64" ] && mv $prefix/lib64/* $prefix/lib/

 mkdir -p "$prefix/include" # make sure target directory exists
 for header in $prefix/lib/libffi-*/include/*
 do
  [ -f "$header" ] && ln -sf "$header" "$prefix/include/$(basename $header)"
 done

 return 0
}
