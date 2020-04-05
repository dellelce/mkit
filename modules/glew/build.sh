
#
# glew
build_glew()
{
 # push in our otions for greater flexibility
 sed -i -e 's/\.EXTRA/_EXTRA/g' $srcdir_glew/Makefile $srcdir_glew/config/Makefile.linux
 sed -i -E -e 's/^CFLAGS(.*)/CFLAGS\1 $(CFLAGS_ENV)/' $srcdir_glew/Makefile
 sed -i -E -e 's/^LIB\.LDFLAGS(.*)/LIB.LDFLAGS\1 $(LDFLAGS_ENV)/' $srcdir_glew/Makefile
#  LDFLAGS_EXTRA = -L/usr/X11R6/lib -L/usr/lib
 sed -i -E -e 's/(.*)LDFLAGS_EXTRA = (.*)/\1LDFLAGS_EXTRA = $(LDFLAGS_ENV) \2/g' \
                            $srcdir_glew/Makefile $srcdir_glew/config/Makefile.linux

 CFLAGS="${BASE_CFLAGS} -I${prefix}/include" \
 LDFLAGS="${BASE_LDFLAGS} -L${prefix}/lib -Wl,-rpath=${prefix}/lib" \
 LDFLAGS_ENV="${LDFLAGS}" \
 LDFLAGS_EXTRA="${LDFLAGS}" \
 CFLAGS_ENV="${CFLAGS}" \
 GLEW_PREFIX="${prefix}" \
 GLEW_DEST="${prefix}" \
 build_raw_core glew $srcdir_glew

 return $?
}
