build_timescaledb()
{
 typeset opwd="$PWD"
 cd "$srcdir_timescaledb"

 BUILD_DIR=${BUILDDIR}/timescaledb \
 ./bootstrap -DPG_CONFIG=${prefix}/bin/pg_config

 cd "$opwd"

 build_raw_core timescaledb $srcdir_timescaledb
 return $?
}
