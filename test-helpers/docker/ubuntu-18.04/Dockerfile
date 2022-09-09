FROM ubuntu:18.04

RUN apt update
RUN apt install -y libfindbin-libs-perl sudo

COPY files /files
RUN find /files/
RUN /files/overte-builder --auto --make-appimage

# Update cmake
RUN sudo apt install -y wget software-properties-common
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | sudo apt-key add -
RUN sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
RUN sudo apt-get update
RUN sudo apt-get install -y cmake

