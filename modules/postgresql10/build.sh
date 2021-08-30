# postgresql10
#
build_postgresql10()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
 build_gnuconf postgresql10 $srcdir_postgresql10    \
                            --disable-rpath         \
                            --with-openssl          \
                            --enable-thread-safety

 return $?
}
