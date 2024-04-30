profile_curl()
{
 add_run_dep openssl
 add_run_dep curl

 return $?
}
