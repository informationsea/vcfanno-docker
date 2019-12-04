FROM alpine:3.10 AS download
RUN apk add curl
RUN curl -o /usr/local/bin/vcfanno -L https://github.com/brentp/vcfanno/releases/download/v0.3.2/vcfanno_linux64
RUN chmod +x /usr/local/bin/vcfanno

FROM alpine:3.10
RUN apk add --no-cache python3 bash
RUN pip3 install toml
COPY --from=download /usr/local/bin/vcfanno /usr/local/bin/vcfanno
