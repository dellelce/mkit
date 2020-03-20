# pcre
#
build_pcre()
{
 build_gnuconf pcre $srcdir_pcre # AUTOCONF=: AUTOHEADER=: AUTOMAKE=: ACLOCAL=:
 return $?
}
