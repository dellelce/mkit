build_wayland()
{
 typeset args=""

 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"

 # only build documentation if doxygen is available
 type doxygen > /dev/null 2>&1
 [ $? -eq 1 ] && args="$args --disable-documentation"

 build_gnuconf wayland $srcdir_wayland $args
 return $?
}
