FROM alpine:latest as build

MAINTAINER Antonio Dell'Elce

ARG BUILDDIR
ENV BUILDDIR  /app-build

ARG INSTALLDIR
ENV INSTALLDIR  /app/httpd

WORKDIR $BUILDDIR
COPY . $BUILDDIR

RUN  apk add --no-cache  gcc bash wget perl file xz make dev86 &&  \
     ls -lta $BUILDDIR &&      \
     bash /app-build/mkit.sh $INSTALLDIR

