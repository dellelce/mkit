build_gcc7()
{
 MAKEINFO=: \
 build_gnuconf gcc7 $srcdir_gcc7 \
                   --enable-languages=c \
                   --with-gmp=${prefix} \
                   --with-mpfr=${prefix} \
                   --with-mpc=${prefix} \
                   --disable-multilib \
                   --disable-lto \
                   --with-system-zlib \
                   --disable-nls
 return $?
}
