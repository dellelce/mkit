# generate Makefiles with cmake/"bootstrap"

 cd ${BUILDDIR}/timescaledb
 cmake "${srcdir_timescaledb}"  -DPG_CONFIG=${prefix}/bin/pg_config
