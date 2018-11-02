ARG BASE=alpine:3.8
FROM $BASE as build

MAINTAINER Antonio Dell'Elce

ENV BUILDDIR  /app-build

ARG PREFIX=/app/httpd
ENV INSTALLDIR  ${PREFIX}

ARG PROFILE=default

# gcc, g++        C/C++ compilers
# bash            needed by mkit.sh & srcget-sh
# wget            builtin wget does not work for us
# perl            I'll pass...
# file            no magic inside
# xz              xz is the "best"
# libc-dev        headers
# linux-headers   more headers
# sed             needed by mkit.sh modules
ENV PACKAGES gcc bash wget perl perl-dev file xz make libc-dev linux-headers g++ sed

WORKDIR $BUILDDIR
COPY . $BUILDDIR

# Build and do not keep "static libraries"
RUN  apk add --no-cache  $PACKAGES &&  \
     bash ${BUILDDIR}/docker.sh $INSTALLDIR && \
     rm -f ${INSTALLDIR}/lib/*.a

# Second Stage
ARG BASE=alpine:latest
FROM $BASE AS final

ARG PREFIX=/app/httpd
ENV INSTALLDIR  ${PREFIX}

RUN mkdir -p ${INSTALLDIR} && \
    apk add --no-cache libgcc

WORKDIR ${INSTALLDIR}
COPY --from=build ${INSTALLDIR} .
RUN { du -ks .; du -ks *| sort -n; } | awk ' \
    BEGIN { print "Space usage in install directory: KB, % & directory name"; } \
    FNR == 1 { total = $1; next; }           \
    $1 > 500 { printf ("%10d %03.3f%% %s\n", $1, ($1 / total) * 100, $2); } '
