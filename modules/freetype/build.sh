#
# freetype
#
build_freetype()
{
 # our CFLAGS is overwritten or "ignored" by freetype
 build_gnuconf freetype $srcdir_freetype
 return $?
}
