#
# bind
#
build_bind()
{
 typeset rc local_venv
 [ -z "$VIRTUAL_ENV" ] &&
 {
  local_venv="/tmp/venv_$RANDOM"

  mkdir "$local_venv" && python3 -m venv "$local_venv" && . "$local_venv/bin/activate"
  [ $? -ne 0 ] && return 1
 }
 pip3 install ply # this should be run in a virtualenv
 build_gnuconf bind $srcdir_bind  --with-openssl=${prefix} \
				  --disable-symtable	   \
				  --disable-linux-caps
 rc=$?

 [ -d "$local_venv" ] &&
 {
   rm -rf "$local_venv"
 }
 return $rc
}
