arg BASE_IMAGE
from ${BASE_IMAGE}

run yum install -y kazoo-application* sysvinit-tools && \
  yum clean all && \
  /sbin/kazoo-applications prepare

cmd /sbin/kazoo-applications start
