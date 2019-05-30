build_inputproto()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"; build_gnuconf inputproto $srcdir_inputproto 
 return $?
}
