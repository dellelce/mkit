profile_haproxy()
{
 add_options pcre "--enable-jit"

 add_run_dep pcre
 add_run_dep zlib
 add_run_dep ncurses # needed by readline
 add_run_dep readline # required by lua
 add_run_dep openssl
 add_run_dep lua
 add_run_dep haproxy

 return $?
}
