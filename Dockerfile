FROM alpine:latest as builder

RUN apk update && apk --no-cache add \
    build-base \
    linux-headers \
    git
WORKDIR /
ARG version=6.2.6
RUN wget -O hashcat.zip https://github.com/hashcat/hashcat/archive/refs/tags/v${version}.zip \
&& unzip hashcat.zip
RUN mv hashcat-${version} hashcat
RUN cd hashcat && make -j2

#RUN git clone --depth=1 https://github.com/hashcat/hashcat \
#&& cd hashcat \
#&& git submodule update --init \
#&& make -j2

From alpine:latest
LABEL maintainer="https://github.com/double16"

RUN apk update && apk --no-cache add shadow
RUN adduser -D -h /home/hashcat hashcat

COPY --from=builder /hashcat/hashcat /hashcat/OpenCL /hashcat/
ENV PATH $PATH:/hashcat
EXPOSE 6863
USER hashcat
WORKDIR /home/hashcat/
RUN mkdir -p /home/hashcat/.local/share/hashcat
VOLUME /home/hashcat/.local/share/hashcat
ENTRYPOINT [ "/hashcat/hashcat", "--brain-server", "--brain-port", "6863" ]
