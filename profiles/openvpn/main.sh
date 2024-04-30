profile_openvpn()
{
 profile_gnudev
 add_run_dep openssl
 add_run_dep lzo
 #we don't want you "linuxpam"
 #add_run_dep linuxpam
 add_run_dep openvpn
 return $?
}
