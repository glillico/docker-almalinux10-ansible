FROM almalinux:10-kitten
LABEL maintainer="Graham Lillico"

ENV container=docker

# Update packages to the latest version
RUN dnf -y update \
&& dnf -y autoremove \
&& dnf clean all \
&& rm -rf /var/cache/dnf/*

# Configure systemd.
# See https://hub.docker.com/_/centos/ for details.
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install required packages.
# Remove packages that are nolonger requried.
# Clean the dnf cache.
RUN dnf -y install \
initscripts \
&& dnf -y update \
&& dnf -y install \
python3 \
python3-pip \
sudo \
&& dnf -y autoremove \
&& dnf clean all \
&& rm -rf /var/cache/dnf/*

# Upgrade pip.
RUN pip3 install --upgrade pip \
&& pip3 install ansible \
&& pip3 cache purge

# Create ansible directory and copy ansible inventory file.
RUN mkdir /etc/ansible \
&& echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/lib/systemd/systemd"]
