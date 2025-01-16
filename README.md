# mkit

Download and Build (from source) complete stacks. The latest version available for each package is downloaded.

## Configuration variables

  * NO_TIMESTAMP: do not use a time stamp for "build" and "src" directories
  * KEEP_DOCS (Docker only): do not delete documentation directories.

## PROFILES:

"mkit" build software defined by a "profile", each profile is defined by a series of "modules" defined in

```
mkit.profiles.sh
```

the modules themselves are defined in the ``modules`` directory.

Here follow a list of the supported profiles:

| Name        | Description                                  |
|-------------|----------------------------------------------|
| gnudev      | Common tools for GNU development             |
| default     | Original profile: Apache, Python, PHP        |
| redis       | Redis (Key-value data store)                 |
| python      | Python 3                                     |
| uwsgi       | Python WSGI & HTTP Server                    |
| postgres    | Postgres (Latest)                            |
| postgres10  | Postgres (10 only)                           |
| timescaledb | Postgres time-series extension               |
| openvpn     | Classic SSL VPN                              |
| gcc         |                                              |
| gcc7        |                                              |
| gccgo7      |                                              |
| curl        |                                              |
| varnish     | Http Cache Server                            |
| haproxy     | Http Load Balancer                           |
| shared      | Shared toolery                               |
| slcp        | Shell prompt with git support                |
| git         |                                              |
| readline    |                                              |
| imagemagick | ImageMagick graphics toolkit                 |
| bind        | Standard DNS Library / Toolkit               |
| cairo       | Standard 2d Graphics Library                 |
| libgit2     | pure C implementation of the core git methods|
