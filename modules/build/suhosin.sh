# suhosin: phpize required to be run in source directory
#
build_suhosin()
{
 {
  echo "Running phpize in $srcdir_suhosin"
  cwd="$PWD"
  cd $srcdir_suhosin
  phpize
  cd "$cwd"
 }
 build_gnuconf suhosin $srcdir_suhosin
 return $?
}
