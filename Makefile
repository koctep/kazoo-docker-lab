PROJECT ?= kazoo

-include .env
include make/images.mk
include make/env.mk

FROM ?= ext1000
TO ?= 1001
CONTEXT ?= inbound
CALLBACK ?= play
CALL_VARS ?= absolute_codec_string=PCMU
ORIGINATE_CMD = bgapi originate {$(CALL_VARS)}sofia/gateway/device.$(FROM)/$(TO)@kama.kz;fs_path=sip:172.17.18.3 $(CALLBACK) XML $(CONTEXT)

TEST ?= internal-calls
include tests/$(TEST).mk

wait-for-regs: start force
	$(MAKE) connect/fs-devices RUN='fs_cli -x "sofia profile devices register all"'
	$(MAKE) connect/fs-devices RUN='wait-for-regs.sh'

device/originate: force
	$(docker) exec fs-devices fs_cli -x '$(ORIGINATE_CMD)'

connect/fs-devices: RUN = fs_cli
connect/%: RUN = bash
connect/%: force
	$(docker) exec -it $* $(RUN)

docker-prune: $(call tasks,image-rm) image-rm/base force
	$(docker) rm -f -v -s || exit 0
	docker system prune -f || exit 0
	docker system prune -f || exit 0

force:
