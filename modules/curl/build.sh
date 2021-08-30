build_curl()
{
 build_gnuconf curl $srcdir_curl --with-openssl
 return $?
}
