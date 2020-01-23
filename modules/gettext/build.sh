#
# gettext
#
build_gettext()
{
 build_gnuconf gettext $srcdir_gettext
 return $?
}
