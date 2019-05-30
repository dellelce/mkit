build_xcb()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"; build_gnuconf xcb $srcdir_xcb 
 return $?
}
