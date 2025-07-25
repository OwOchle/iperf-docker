FROM alpine:latest AS build

RUN ["apk", "add", "musl-dev", "wget", "gcc", "make", "autoconf", "automake", "libtool"]
WORKDIR /home
RUN ["wget", "https://downloads.es.net/pub/iperf/iperf-3.19.1.tar.gz"]
RUN wget https://downloads.es.net/pub/iperf/iperf-3.19.1.tar.gz.sha256 -O - | sha256sum -c
RUN ["tar", "-xvf", "iperf-3.19.1.tar.gz"]
WORKDIR /home/iperf-3.19.1
RUN ["./bootstrap.sh"]
RUN ["./configure"]
RUN ["sh", "-c", "make -j$(nproc)"]
RUN ["mkdir", "bin"]
RUN ["make", "install", "DESTDIR=/home/iperf-3.19.1/bin"]

FROM alpine:latest AS run

COPY --from=build /home/iperf-3.19.1/bin/ /

EXPOSE 5201

ENTRYPOINT ["iperf3"]
CMD ["-s"]
