build_glu()
{
 CPPFLAGS="$CFLAGS" \
 CXXFLAGS="$CFLAGS" \
 build_gnuconf glu $srcdir_glu
 return $?
}
