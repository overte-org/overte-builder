FROM ubuntu:24.04


RUN apt update
RUN apt install -y libfindbin-libs-perl sudo xdg-user-dirs

COPY files /files
RUN find /files/
RUN /files/overte-builder --auto




