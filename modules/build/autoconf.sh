# GNU autoconf
#
build_autoconf()
{
 typeset rc=0
 # include pre-existing aclocal path if any
 type aclocal >/dev/null 2>&1
 rc=$?

 [ "$rc" -eq 0 ]  &&
 {
   export ACLOCAL_PATH="${prefix}/share/aclocal:$(aclocal --print-ac-dir)"
 }

 build_gnuconf autoconf $srcdir_autoconf
 return $?
}
