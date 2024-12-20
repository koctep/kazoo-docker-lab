arg BASE_IMAGE
from ${BASE_IMAGE}

run yum install -y kazoo-application* monster-ui* sysvinit-tools jq pwgen && \
  yum clean all && \
  /sbin/kazoo-applications prepare

copy config.ini /etc/kazoo/core
copy sys.config /etc/kazoo/core
copy init.sh /usr/local/bin

cmd /sbin/kazoo-applications start
