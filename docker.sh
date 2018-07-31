#!/bin/bash
#
# Building for docker // this is only needed until mkit does not have proper testing
#
# File:         docker.sh
# Created:      250718
#

### FUNCTIONS ###

test_file()
{
 typeset f="$1"
 typeset basef="$(basename $f)"

 [ ! -f "$f" ] && { echo "File $f does not exist."; return 1; }

 echo "File ${basef} exists."
 ls -lt "$f"

 return 0
}

test_any()
{
 typeset f="$1"
 typeset basef="$(basename $f)"

 [ ! -e "$f" ] && { echo "$f does not exist."; return 1; }

 echo "File ${basef} exists."
 ls -lt "$f"

 return 0
}

test_dir()
{
 typeset d="$1"

 [ ! -d "$d" ] && { echo "Directory $d does not exist."; return 1; }
 return 0
}

main_tests()
{
 echo "Starting tests..."
 test_dir  "$prefix/bin"
 rc_bin=$?
 [ "$rc_bin" -ne 0 ] && let fails="(( $fails + 1))"

 fails=0

 test_file $python
 rc_python=$?

 rc_sslversion=0
 rc_readline=0

 [ "$rc_python" -eq 0 ] &&
 {
  echo "Testing correct OpenSSL module is built:"
  echo "import _ssl; print(_ssl.OPENSSL_VERSION);" | ${python}
  rc_sslversion=$?

  echo "Testing readline"
  echo "import readline;" | ${python}
  rc_readline="$?"
 } ||
 {
  let fails="(( $fails + 1))"
 }

 [ "$rc_sslversion" -ne 0 ] && let fails="(( $fails + 1))"
 [ "$rc_readline" -ne 0 ] && let fails="(( $fails + 1))"

 # mod_wsgi checks
 test_file "$prefix/modules/mod_wsgi.so" || let fails="(( $fails + 1))"
 test_file "$prefix/modules/mod_proxy_uwsgi.so" || let fails="(( $fails + 1))"

 # readline
 test_any "$prefix/lib/libhistory.a" || let fails="(( $fails + 1))"
 test_any "$prefix/lib/libhistory.so.7.0" || let fails="(( $fails + 1))"
 test_any "$prefix/lib/libhistory.so.7" || let fails="(( $fails + 1))"
 test_any "$prefix/lib/libhistory.so" || let fails="(( $fails + 1))"
 test_any "$prefix/lib/libreadline.a" || let fails="(( $fails + 1))"
 test_any "$prefix/lib/libreadline.so.7.0" || let fails="(( $fails + 1))"

 echo
 ls -lt "${prefix}/bin"

 [ "$rc" -eq 0 -a "$fails" -ne 0 ] &&
 {
  echo "Build succeeded but there were $fails test failures!"
  return 1
 }

 return $rc
}

### ENV ###

prefix="$1"
python="$prefix/bin/python3.7"
export fails=0

### MAIN ###

mkdir -p $prefix && ./mkit.sh $prefix
rc=$?

echo "mkit rc: $rc"

# even if rc != 0: we do some tests anyway
main_tests || exit $?

### EOF ###
