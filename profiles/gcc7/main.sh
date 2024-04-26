profile_gcc7()
{
 add_build_dep m4
 add_run_dep zlib
 add_run_dep binutils
 add_run_dep gmp
 add_run_dep mpfr
 add_run_dep mpc
 add_run_dep gcc7
 return $?
}
