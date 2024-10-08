ARG BASE=alpine:3.19
FROM $BASE as build

LABEL maintainer="Antonio Dell'Elce"

ENV BUILDDIR  /app-build

ARG PROFILE=default
ARG PREFIX=/app/httpd
ENV INSTALLDIR  ${PREFIX}

WORKDIR $BUILDDIR
COPY . $BUILDDIR

# Package requirements
ENV PACKAGES gcc bash wget perl perl-dev automake autoconf libtool file xz \
             make libc-dev linux-headers g++ sed bison flex cmake gfortran \
             awk grep

# Build and do not keep "static libraries"
RUN  mkdir -p ${INSTALLDIR}/lib && ln -s ${INSTALLDIR}/lib64 ${INSTALLDIR}/lib && \
     apk add --no-cache  $PACKAGES &&  \
     bash ${BUILDDIR}/docker.sh $INSTALLDIR && \
     rm -f ${INSTALLDIR}/lib/*.a

# Second Stage
ARG BASE=alpine:3.19
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
