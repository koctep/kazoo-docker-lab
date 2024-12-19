from centos:7

run sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
run yum upgrade -y --skip-broken
run yum install -y epel-release
run yum install -y iproute tcpdump
run yum clean all

run printf "[2600hz-stable]\nname=2600Hz Stable Repo\nbaseurl=https://packages.2600hz.com/centos/\$releasever/stable\nenabled=1\ngpgcheck=0" \
  > /etc/yum.repos.d/2600Hz.repo

run sed -i -r 's/^(session\s+required\s+pam_limits.so)/#\1/' /etc/pam.d/*

cmd bash
