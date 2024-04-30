profile_timescaledb()
{
 add_build_dep cmake
 add_build_dep bison # only when building from commit/tag/branch (not "packaged" source)
 profile_postgres
 add_run_dep timescaledb
 return $?
}
