build_nettle()
{
 typeset rc=0

 build_gnuconf nettle $srcdir_nettle; rc=$?

 return $?
}
