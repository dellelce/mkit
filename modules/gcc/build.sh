# TODO: support cross-compiling
# TODO: c++ is pushed in into languages, why?
build_gcc()
{
 typeset languages="c"
 typeset args="$*"
 typeset rc=0
 typeset extra_args=""

 [ ! -z "$args" ] && languages="${languages},${args}"

 [ -z "$LD_LIBRARY_PATH" ] &&
 {
   export LD_LIBRARY_PATH="$prefix/lib"
 } ||
 {
   OLD_LP="$LD_LIBRARY_PATH"
   export LD_LIBRARY_PATH="$prefix/lib:$LD_LIBRARY_PATH"
 }

 [ -f "/etc/alpine-release" ] &&
 {
   extra_args="--disable-libssp --disable-libmpx --disable-libmudflap --disable-libsanitizer"
   extra_args="${extra_args} --disable-gomp --disable-libatomic"
 }

 MAKEINFO=: \
 build_gnuconf gcc $srcdir_gcc \
                   --enable-languages=${languages} \
                   --with-gmp=${prefix} \
                   --with-mpfr=${prefix} \
                   --with-mpc=${prefix} \
                   --disable-multilib \
                   --disable-lto \
                   --with-system-zlib \
                   --disable-nls \
                   ${extra_args}

 rc=$?
 [ ! -z "$OLD_LP" ] && { LD_LIBRARY_PATH="$OLD_LP"; unset OLD_LP; }

 return $rc
}
