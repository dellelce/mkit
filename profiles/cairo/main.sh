profile_cairo()
{
 #this will be needed when moving from alpine 3.8 to 3.9
 #add_build_dep pkgconfig
 add_run_dep zlib
 add_run_dep libpng
 add_run_dep freetype
 add_run_dep gperf
 add_run_dep expat
 #I thought uuid was not mandatory, temporarily re-disabling
 #add_run_dep fontconfig
 add_run_dep pixman
 add_run_dep cairo
}
