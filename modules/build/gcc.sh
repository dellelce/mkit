build_gcc()
{
 typeset languages="c"
 typeset args="$*"
 typeset rc=0

 [ ! -z "$args" ] && languages="${languages},${args}"

 [ -z "$LD_LIBRARY_PATH" ] &&
 {
   export LD_LIBRARY_PATH="$prefix/lib"
 } ||
 {
   OLD_LP="$LD_LIBRARY_PATH"
   export LD_LIBRARY_PATH="$prefix/lib:$LD_LIBRARY_PATH"
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
                   --disable-nls
 rc=$?

 [ ! -z "$OLD_LP" ] && { LD_LIBRARY_PATH="$OLD_LP"; unset OLD_LP; }

 return $rc
}
