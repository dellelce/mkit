# TODO: automate build orders & list
profile_default()
{
 profile_gnubuild
 profile_python
 add_build_dep bison
 add_run_dep expat
 add_run_dep pcre
 add_run_dep apr
 add_run_dep aprutil
 add_run_dep libxml2
 add_run_dep httpd

 [ "$PHP_NEEDED" == "1" ] &&
 {
  add_run_dep php
  add_run_dep suhosin
 }

 add_run_dep python3
 add_run_dep mod_wsgi

 return $?
}
