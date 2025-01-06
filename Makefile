PREFIX ?= kz-
BASE_IMAGE := $(PREFIX)base
components := $(shell for f in $$(ls -1 src/images/*/Dockerfile | grep -v '^base'); do basename $$(dirname $$f); done)
images := $(foreach component, $(components), $(PREFIX)$(component))

define tasks
$(foreach image, $(components), $(1)/$(image))
endef

FROM ?= ext1000
TO ?= 1001
ORIGINATE_CMD = bgapi originate sofia/gateway/device.$(FROM)/$(TO)@kama.kz play XML inbound

TEST ?= internal-calls
ifneq ($(TEST),)
include tests/$(TEST).mk
endif

run: env force
	docker compose up

start: env force
	docker compose create
	docker compose start

stop: force
	docker compose stop

ps: force
	docker compose ps

wait-for-regs: start force
	$(MAKE) connect/fs-devices RUN='fs_cli -x "sofia profile devices register all"'
	$(MAKE) connect/fs-devices RUN='wait-for-regs.sh'

env: images-create .env

env-rm: force
	docker compose stop || exit 0
	docker compose rm -f || exit 0

images-create: $(call tasks,image-update) force

images-rm: $(call tasks,image-rm) force

images-update: $(call tasks,image-update) force

image-create/$(BASE_IMAGE): force
	docker inspect $(BASE_IMAGE) >/dev/null || docker build -t $(BASE_IMAGE) src/images/base
image-create/%: image-create/$(BASE_IMAGE) force
	docker inspect $(PREFIX)$* >/dev/null || \
	docker build --build-arg BASE_IMAGE=$(BASE_IMAGE) -t $(PREFIX)$* src/images/$*

image-rm/%: force
	docker image rm -f $(PREFIX)$* || exit 0

image-update/%: image-rm/% image-create/%
	@echo updated $*

.env:
	echo "ROOT_DIR=$(PWD)" > .env
	echo "PREFIX=$(PREFIX)" >> .env

device/originate: force
	docker compose exec fs-devices $(ORIGINATE_CMD)

connect/fs-devices: RUN = fs_cli
connect/%: RUN = bash
connect/%: force
	docker compose exec -it $* $(RUN)

docker-prune: $(call tasks,image-rm) image-rm/base force
	docker compose rm -f -v -s || exit 0
	docker system prune -f || exit 0
	docker system prune -f || exit 0

force:

-include Makefile.custom
