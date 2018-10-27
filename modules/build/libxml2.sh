build_libxml2()
{
 build_gnuconf libxml2 $srcdir_libxml2 --without-python

 return $?
}
