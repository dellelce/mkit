# syntax=docker/dockerfile:experimental
ARG BASE=alpine:3.8
FROM $BASE as build

LABEL maintainer="Antonio Dell'Elce"

ENV BUILDDIR  /app-build

RUN --mount=type=tmpfs,target=${BUILDDIR}

ARG PROFILE=default
ARG PREFIX=/app/httpd
ENV INSTALLDIR  ${PREFIX}

WORKDIR $BUILDDIR
COPY . $BUILDDIR

# Package requirements
ENV PACKAGES gcc bash wget perl perl-dev automake autoconf libtool file xz make libc-dev linux-headers g++ sed bison cmake

# Build and do not keep "static libraries"
RUN  apk add --no-cache  $PACKAGES &&  \
     bash ${BUILDDIR}/docker.sh $INSTALLDIR && \
     rm -f ${INSTALLDIR}/lib/*.a

# Second Stage
ARG BASE=alpine:latest
FROM $BASE AS final

ARG PREFIX=/app/httpd
ENV INSTALLDIR  ${PREFIX}
ENV PATH        ${PREFIX}/bin:${PATH}

RUN mkdir -p ${INSTALLDIR} && \
    apk add --no-cache libgcc

WORKDIR ${INSTALLDIR}
COPY --from=build ${INSTALLDIR} .
RUN { du -ks .; du -ks *| sort -n; } | awk ' \
    BEGIN { print "Space usage in install directory: KB, % & directory name"; } \
    FNR == 1 { total = $1; next; }           \
    $1 > 500 { printf ("%10d %03.3f%% %s\n", $1, ($1 / total) * 100, $2); } '
