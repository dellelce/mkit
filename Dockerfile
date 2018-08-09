FROM alpine:latest as build

MAINTAINER Antonio Dell'Elce

ENV BUILDDIR  /app-build
ARG installpath=/app/httpd
ENV INSTALLDIR  ${installpath}

# gcc             most of the source needs gcc
# bash            busybox does not support some needed features of bash like "typeset"
# wget            builtin wget does not work for us
# perl            I'll pass...
# file            no magic inside
# xz              xz is the "best"
# libc-dev        headers
# linux-headers   more headers
ENV PACKAGES gcc bash wget perl file xz make libc-dev linux-headers g++

WORKDIR $BUILDDIR
COPY . $BUILDDIR

# Build and do not keep "static libraries"
RUN  apk add --no-cache  $PACKAGES &&  \
     bash ${BUILDDIR}/docker.sh $INSTALLDIR && \
     rm ${INSTALLDIR}/lib/*.a

# Second Stage
FROM alpine:latest AS final

ENV INSTALLDIR  /app/httpd

RUN mkdir -p ${INSTALLDIR} && \
    apk add --no-cache libgcc

WORKDIR ${INSTALLDIR}
COPY --from=build ${INSTALLDIR} .
RUN du -ks .
