#!/bin/bash
#
# Building for run-workflow
# This is only used by non-Docker build as a wrapper to mkit.sh to add testing
#
# File:         run-workflow.sh
# Created:      250718
#

### FUNCTIONS ###

test_file()
{
 typeset f="$1"
 typeset basef="$(basename $f)"

 [ ! -f "$f" ] && { echo "File $f does not exist."; return 1; }

 echo "${basef} exists."
 ls -lt "$f"

 # shared library test
 [ "${basef%.so}" != "${basef}" ] && { ldd "$f" ||  return $?; }

 return 0
}

### ENV ###

prefix="$1"; shift
python="$prefix/bin/python3.8"

### MAIN ###

mkdir -p $prefix && ./mkit.sh $prefix
rc=$?

echo "mkit rc: $rc"
fails=0

# even if rc != 0: we do some tests anyway

test_file $python
rc_python=$?

rc_sslversion=0
[ "$rc_python" -eq 0 ] &&
{
 echo "Testing correct OpenSSL module is built:"
 echo "import _ssl; print(_ssl.OPENSSL_VERSION);" | ${python}
 rc_sslversion=$?
} ||
{
 let fails="(( $fails + 1))"
}

[ "$rc_sslversion" -ne 0 ] && let fails="(( $fails + 1))"

# mod_wsgi checks
f="$prefix/modules/mod_wsgi.so"
test_file  $f || let fails="(( $fails + 1 ))"

f="$prefix/modules/mod_proxy_uwsgi.so"
test_file  $f || let fails="(( $fails + 1 ))"

#
echo
ls -lt "${prefix}/bin"

[ "$rc" -eq 0 -a "$fails" -ne 0 ] && { echo "Build succeeded but there were $fails test failures!"; exit 1; }

exit $rc

### EOF ###
