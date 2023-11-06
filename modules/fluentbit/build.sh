build_fluentbit()
{
 [ -f "/etc/alpine-release" ] && apk add --no-cache fts-dev

 build_raw_lite fluentbit

 return $?
}
