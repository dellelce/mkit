profile_git()
{
 profile_gnubuild
 add_run_dep zlib
 add_run_dep git

 return $?
}
