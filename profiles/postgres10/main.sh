profile_postgres10()
{
 add_run_dep openssl
 add_run_dep libxml2
 add_run_dep zlib
 add_run_dep ncurses
 add_run_dep readline
 add_run_dep postgresql10
 return $?
}
