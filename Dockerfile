FROM alpine:latest as build

MAINTAINER Antonio Dell'Elce

ARG BUILDDIR
ENV BUILDDIR  /app-build

ARG INSTALLDIR
ENV INSTALLDIR  /app/httpd

WORKDIR $BUILDDIR
COPY . $BUILDDIR

RUN  apk add --no-cache  gcc bash wget perl file xz make libc-dev &&  \
     ls -lta $BUILDDIR &&      \
     bash ${BUILDDIR}/mkit.sh $INSTALLDIR && \
     ls -lt $INSTALLDIR && \
     ls -lt $INSTALLDIR/bin && \
     echo "import _ssl; print(_ssl.OPENSSL_VERSION);" | $INSTALLDIR/bin/python3

