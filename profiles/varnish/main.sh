profile_varnish()
{
 # varnish needs python (">= 2.7") for generating some files
 # build time dependency only so these should not stay here...
 #
 profile_python
 profile_gnubuild

 # temporary workaround for missing backtrace() in musl
 [ -f "/etc/alpine-release" ] &&
 {
   apk add --no-cache libexecinfo-dev
 }

 add_run_dep pcre
 add_run_dep ncurses
 add_run_dep readline
 add_run_dep varnish

 return $?
}
