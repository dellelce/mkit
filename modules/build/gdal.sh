build_gdal()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"

 opt="BADCONFIGURE" \
 build_gnuconf gdal $srcdir_gdal --with-proj=$prefix
 return $?
}
