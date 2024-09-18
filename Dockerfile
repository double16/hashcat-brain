FROM alpine:latest as builder

ARG version=6.2.6

RUN apk update && apk --no-cache add \
    build-base \
    linux-headers \
    git
WORKDIR /
RUN wget -O hashcat.zip https://github.com/hashcat/hashcat/archive/refs/tags/v${version}.zip \
&& unzip hashcat.zip
RUN mv hashcat-${version} hashcat
RUN cd hashcat && make -j2

From alpine:latest
LABEL maintainer="https://github.com/double16"

RUN apk update && apk --no-cache add shadow
RUN adduser -D -h /home/hashcat hashcat

COPY --from=builder /hashcat/hashcat /hashcat/OpenCL /hashcat/
EXPOSE 6863
USER hashcat
WORKDIR /home/hashcat/
VOLUME /home/hashcat/
ENTRYPOINT [ "/hashcat/hashcat", "--brain-server", "--brain-port", "6863" ]
