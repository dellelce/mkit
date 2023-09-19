#
build_binutils()
{
# try harder to skip makeinfo stuff
 mkdir bin
 echo ': $*' >bin/makeinfo
 chmod +x bin/makeinfo
 export PATH=$PWD/bin:$PATH

 build_gnuconf binutils $srcdir_binutils

 return $?
}
