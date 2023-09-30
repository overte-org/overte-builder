FROM opensuse/tumbleweed


RUN zypper update -y
RUN zypper install -y perl sudo
COPY files /files
RUN /files/overte-builder --auto




