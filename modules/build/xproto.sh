build_xproto()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"; build_gnuconf xproto $srcdir_xproto 
 return $?
}
