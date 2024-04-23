FROM fedora:40


RUN dnf update -y
RUN dnf install -y perl
COPY files /files
RUN /files/overte-builder --auto




