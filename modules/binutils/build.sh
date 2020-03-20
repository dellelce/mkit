#
build_binutils()
{
 build_gnuconf binutils $srcdir_binutils MAKEINFO=:
 return $?
}
