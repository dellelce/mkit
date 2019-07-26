# generate Makefiles with cmake/"bootstrap"

 args=""

 [ $(type python3 >/dev/null  2>&1) -eq 1 ] && { args="$args -DBUILD_CLAR=OFF"; }

 cd ${BUILDDIR}/libgit2
 cmake "${srcdir_libgit2}"  -DCMAKE_INSTALL_PREFIX=${prefix} $args
