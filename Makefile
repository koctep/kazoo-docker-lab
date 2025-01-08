PROJECT ?= kazoo

-include .env
include make/images.mk
include make/env.mk

FROM ?= ext1000
TO ?= 1001
ORIGINATE_CMD = bgapi originate sofia/gateway/device.$(FROM)/$(TO)@kama.kz play XML inbound

TEST ?= internal-calls
include tests/$(TEST).mk

wait-for-regs: start force
	$(MAKE) connect/fs-devices RUN='fs_cli -x "sofia profile devices register all"'
	$(MAKE) connect/fs-devices RUN='wait-for-regs.sh'

device/originate: force
	$(docker) exec fs-devices $(ORIGINATE_CMD)

connect/fs-devices: RUN = fs_cli
connect/%: RUN = bash
connect/%: force
	$(docker) exec -it $* $(RUN)

docker-prune: $(call tasks,image-rm) image-rm/base force
	$(docker) rm -f -v -s || exit 0
	docker system prune -f || exit 0
	docker system prune -f || exit 0

force:
