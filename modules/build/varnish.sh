build_varnish()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"

 RST2MAN=: SPHINX=: \
 build_gnuconf varnish $srcdir_varnish
 return $?
}
