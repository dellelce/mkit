
# add support for downloading varnish from custom commit
[ ! -z "$varnishcommit" ] &&
{
 commit="${varnishcommit}"
 fname="$PWD/varnish-${commit}.tar.gz"
 ghpath="varnishcache/varnish-cache"
 fullurl="https://github.com/${ghpath}/archive/${commit}.tar.gz"
 wget -q -O "$fname" "$fullurl"
 rc=$?

 [ -f "$fname" ] && echo "$fname"

 exit $rc
}

exit 0
