PREFIX ?= kz-
BASE_IMAGE := $(PREFIX)base
components := $(shell for f in $$(ls -1 docker/images/*/Dockerfile | grep -v '^base'); do basename $$(dirname $$f); done)
images := $(foreach component, $(components), $(PREFIX)$(component))

define tasks
$(foreach image, $(components), $(1)/$(image))
endef

run: env force
	docker compose up

start: env force
	docker compose create
	docker compose start

env: images-create .env

images-create: $(call tasks,image-update) force

images-rm: $(call tasks,image-rm) force

images-update: $(call tasks,image-update) force

image-create/$(BASE_IMAGE): force
	docker inspect $(BASE_IMAGE) >/dev/null || docker build -t $(BASE_IMAGE) docker/images/base
image-create/%: image-create/$(BASE_IMAGE) force
	docker inspect $(PREFIX)$* >/dev/null || \
	docker build --build-arg BASE_IMAGE=$(BASE_IMAGE) -t $(PREFIX)$* docker/images/$*

image-rm/%: force
	docker image rm -f $(PREFIX)$* || exit 0

image-update/%: image-rm/% image-create/%
	@echo updated $*

.env:
	echo "ROOT_DIR=$(PWD)" > .env
	echo "PREFIX=$(PREFIX)" >> .env

device/originate: FROM ?= ext1000
device/originate: TO ?= 1001
device/originate: force
	docker compose exec fs-devices \
		fs_cli -x 'bgapi originate sofia/gateway/device.$(FROM)/$(TO)@kama.kz play XML inbound'

connect/%: RUN = bash
connect/%:
	docker compose exec -it $* $(RUN)

docker-prune: $(call tasks,image-rm) image-rm/base force
	docker compose rm -f -v -s || exit 0
	docker system prune -f || exit 0
	docker system prune -f || exit 0

force:
