arg BASE_IMAGE
from ${BASE_IMAGE}

run yum install -y kazoo-applications && \
  yum clean all && \
  /sbin/kazoo-applications prepare

cmd /sbin/kazoo-applications start
