#
build_uwsgi()
{
 typeset rc=0 dir=""

 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"

 # we kindly ask you to use our preferred version of python
 sed -i -e 's/python$/python3/' ${srcdir_uwsgi}/Makefile

 # a proper makefile has always a "make install"...
 {
 cat << EOF

install:
	@cp uwsgi ${prefix}/bin
	@ls -lt ${prefix}/bin/uwsgi

EOF
 } >> "${srcdir_uwsgi}"/Makefile

 CPUCOUNT=1 \
 PYTHON=$prefix/bin/python3 \
 PROFILE="default" \
 build_raw_core uwsgi $srcdir_uwsgi

 return $?
}
