profile_leptonica()
{
 add_run_dep zlib
 add_run_dep libpng
 add_run_dep expat # required by freetype
 add_run_dep gperf # required by fontconfig
 add_run_dep freetype # required by fontconfig
 add_run_dep fontconfig
 add_run_dep leptonica
}
