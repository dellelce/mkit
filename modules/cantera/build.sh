#
# cantera
#
build_cantera()
{
 typeset rc local_venv
 [ -z "$VIRTUAL_ENV" ] &&
 {
  local_venv="/tmp/venv_$RANDOM"

  mkdir "$local_venv" && python3 -m venv "$local_venv" && . "$local_venv/bin/activate"
  [ $? -ne 0 ] && return 1
 }

 pip3 install scons numpy cython wheel &&  # this should be run in a virtualenv
 scons build optimize=n prefix="$prefix" -f "$srcdir_cantera/SConstruct"
 rc=$?

 [ -d "$local_venv" ] &&
 {
   rm -rf "$local_venv"
 }
 return $rc
}
