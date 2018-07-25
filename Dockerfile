FROM alpine:latest as build

MAINTAINER Antonio Dell'Elce

ARG BUILDDIR
ENV BUILDDIR  /app-build

ARG INSTALLDIR
ENV INSTALLDIR  /app/httpd

ARG PACKAGES
ENV PACKAGES gcc bash wget perl file xz make libc-dev linux-headers g++

WORKDIR $BUILDDIR
COPY . $BUILDDIR

RUN  apk add --no-cache  $PACKAGES &&  \
     bash ${BUILDDIR}/docker.sh $INSTALLDIR
