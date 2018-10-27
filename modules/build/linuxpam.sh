# linux-pam
#
build_linuxpam()
{
 build_gnuconf linuxpam $srcdir_linuxpam --disable-nls --disable-db
 return $?
}
