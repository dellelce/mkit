profile_gpaw()
{
 profile_python
 profile_gnubuild    # gpaw needs autoreconf
 profile_cmakebuild  # lapack build requires cmake

 add_run_dep  libxc
 add_run_dep  lapack
 add_run_dep  openblas
 add_run_dep  gpaw
}
