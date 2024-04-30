profile_bind()
{
 # libxml2 & openssl are included in python profile
 # mixing run-time and build-time dependencies is not supported at this time
 # *IF* this means need to link from multiple prefixes)
 profile_python
 add_run_dep libuv
 add_run_dep bind
}
