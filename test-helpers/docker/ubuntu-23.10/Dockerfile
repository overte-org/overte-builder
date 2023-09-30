FROM ubuntu:23.10


RUN apt update
RUN apt install -y libfindbin-libs-perl sudo

COPY files /files
RUN find /files/
RUN /files/overte-builder --auto




