build_gcc7()
{
 typeset languages="c"
 typeset args="$*"

 [ ! -z "$args" ] && languages="${languages},${args}"

 MAKEINFO=: \
 build_gnuconf gcc7 $srcdir_gcc7 \
                   --enable-languages=${languages} \
                   --with-gmp=${prefix} \
                   --with-mpfr=${prefix} \
                   --with-mpc=${prefix} \
                   --disable-multilib \
                   --disable-lto \
                   --with-system-zlib \
                   --disable-nls
 return $?
}
