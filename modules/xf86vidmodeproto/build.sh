build_xf86vidmodeproto()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"; build_gnuconf xf86vidmodeproto $srcdir_xf86vidmodeproto
 return $?
}
