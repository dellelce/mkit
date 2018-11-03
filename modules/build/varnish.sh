build_varnish()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"

 # I would kindly ask not to build man pages
 [ -f "$srcdir_varnish/man/Makefile" ] &&
 {
  echo 'install:' > "$srcdir_varnish/man/Makefile"
 } ||
 {
  echo > "$srcdir_varnish/man/Makefile.am"
 }

 RST2MAN=: SPHINX=: \
 build_gnuconf varnish $srcdir_varnish
 return $?
}
