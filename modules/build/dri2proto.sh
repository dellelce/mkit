build_dri2proto()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"; build_gnuconf dri2proto $srcdir_dri2proto 
 return $?
}
