FROM alpine:3.10 AS download
RUN apk add curl
RUN curl -o /usr/local/bin/vcfanno -L https://github.com/brentp/vcfanno/releases/download/v0.3.2/vcfanno_linux64
RUN chmod +x /usr/local/bin/vcfanno

FROM alpine:3.10 AS download-bcftools
RUN apk add curl libarchive-tools
ENV BCFTOOLS_VERSION=1.10.2
RUN curl -OL https://github.com/samtools/bcftools/releases/download/${BCFTOOLS_VERSION}/bcftools-${BCFTOOLS_VERSION}.tar.bz2
RUN bsdtar xf bcftools-${BCFTOOLS_VERSION}.tar.bz2

FROM alpine:3.10 AS buildenv-bcftools
RUN apk add gcc make libc-dev ncurses-dev bzip2-dev zlib-dev curl-dev curl xz-dev
ENV BCFTOOLS_VERSION=1.10.2
COPY --from=download-bcftools /bcftools-${BCFTOOLS_VERSION} /bcftools-${BCFTOOLS_VERSION}
WORKDIR /bcftools-${BCFTOOLS_VERSION}
RUN ./configure --prefix=/usr
RUN make -j4
RUN make install DESTDIR=/dest

FROM alpine:3.10
RUN apk add --no-cache python3 bash ncurses libbz2 zlib libcurl xz-libs
COPY --from=buildenv-bcftools /dest /
RUN pip3 install toml
COPY --from=download /usr/local/bin/vcfanno /usr/local/bin/vcfanno
