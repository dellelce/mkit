build_postgis()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"

 # remove postgis_svn_revision.h from "all" target as NOT needed.
 sed -i -e 's/all: postgis_svn_revision.h/all:/' $srcdir_postgis/GNUmakefile.in

 opt="BADCONFIGURE" \
 build_gnuconf postgis $srcdir_postgis  --with-pgconfig=$prefix/bin/pg_config \
                                        --with-geosconfig=$prefix/bin/geos-config \
					--with-projdir=$prefix
 return $?
}
