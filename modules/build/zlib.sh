# zlib
#
build_zlib()
{
 # zlib's configure does not support building in a different directory than source
 opt="BADCONFIGURE" \
 build_gnuconf zlib $srcdir_zlib

 return $?
}
