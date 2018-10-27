build_gcc()
{
 MAKEINFO=: \
 build_gnuconf gcc $srcdir_gcc \
                   --enable-languages=c \
                   --with-gmp=${prefix}
                   --with-mpfr=${prefix}
                   --with-mpc=${prefix} \
                   --disable-multilib \
                   --disable-lto \
                   --with-system-zlib \
                   --disable-libstdcxx \
                   --disable-nls
 return $?
}
