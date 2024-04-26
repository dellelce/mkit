profile_uwsgi()
{
 add_options pcre "--enable-jit"

 add_run_dep pcre
 profile_python
 add_run_dep uwsgi
 return $?
}
