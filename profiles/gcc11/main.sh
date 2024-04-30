profile_gcc11()
{
 add_build_dep m4
 add_run_dep zlib
 add_run_dep binutils
 add_run_dep gmp
 add_run_dep mpfr
 add_run_dep mpc
 add_run_dep gcc11
 return $?
}
