# postgresql11
#
build_postgresql11()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
 build_gnuconf postgresql11 $srcdir_postgresql11    \
                            --disable-rpath         \
                            --with-openssl          \
                            --enable-thread-safety


 return $?
}
