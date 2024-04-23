build_gpaw()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig";

 prepare_build

 pip3 install .
 return $?
}
