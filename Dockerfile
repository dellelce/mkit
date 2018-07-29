FROM alpine:latest as build

MAINTAINER Antonio Dell'Elce

ARG BUILDDIR
ENV BUILDDIR  /app-build

ARG INSTALLDIR
ENV INSTALLDIR  /app/httpd

# gcc             most of the source needs gcc
# bash            busybox does not support some needed features of bash like "typeset"
# wget            builtin wget does not
# perl            I'll pass...
# file            no magic inside
# xz              xz is the "best" 
# libc-dev        headers
# linux-headers   more headers
ARG PACKAGES
ENV PACKAGES gcc bash wget perl file xz make libc-dev linux-headers g++

WORKDIR $BUILDDIR
COPY . $BUILDDIR

RUN  apk add --no-cache  $PACKAGES &&  \
     bash ${BUILDDIR}/docker.sh $INSTALLDIR

# Second Stage
FROM alpine:latest AS final

RUN mkdir -p /app/httpd && \
    apk add --no-cache libgcc

WORKDIR /app/httpd
COPY --from=build /app/httpd .
