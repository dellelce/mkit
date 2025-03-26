build_gcc11()
{
 typeset languages="c"
 typeset args="$*"
 typeset arg
 typeset rc=0

 for arg in $args
 do
  # all options that don't have an "=" are treated as a language
  [ "${arg/=/}" != "${arg}" ] && { languages="${languages},${arg}"; continue; }
 done

 [ -z "$LD_LIBRARY_PATH" ] &&
 {
   export LD_LIBRARY_PATH="$prefix/lib"
 } ||
 {
   OLD_LP="$LD_LIBRARY_PATH"
   export LD_LIBRARY_PATH="$prefix/lib:$LD_LIBRARY_PATH"
 }

 MAKEINFO=: \
 build_gnuconf gcc11 $srcdir_gcc11 \
                   --enable-languages=${languages} \
                   --with-gmp=${prefix} \
                   --with-mpfr=${prefix} \
                   --with-mpc=${prefix} \
                   --disable-multilib \
                   --disable-libiberty \
                   --disable-lto \
                   --with-system-zlib \
                   --disable-nls
 rc=$?

 [ ! -z "$OLD_LP" ] && { LD_LIBRARY_PATH="$OLD_LP"; unset OLD_LP; }

 return $rc
}
