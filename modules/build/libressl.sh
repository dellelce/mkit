# libressl
#
build_libressl()
{
 build_gnuconf libressl $srcdir_libressl
 return $?
}
