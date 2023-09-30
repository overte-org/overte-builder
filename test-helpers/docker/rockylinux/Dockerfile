FROM rockylinux:9.2


RUN dnf update -y
RUN dnf install -y perl sudo
COPY files /files
RUN /files/overte-builder --auto




