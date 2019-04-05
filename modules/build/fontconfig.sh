#
# fontconfig
#
build_fontconfig()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
 build_gnuconf fontconfig $srcdir_fontconfig
 return $?
}
