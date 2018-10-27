#
# bison
#
build_bison()
{
 build_gnuconf bison $srcdir_bison MAKEINFO=:
 return $?
}
