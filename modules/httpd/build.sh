# Apache HTTPD
#
build_httpd()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
 build_gnuconf httpd $srcdir_httpd \
                     --with-z="${prefix}"		\
                     --with-apr="${prefix}"		\
                     --with-apr-util="${prefix}"

 return $?
}
