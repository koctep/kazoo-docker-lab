PREFIX ?= kz-
BASE_IMAGE := $(PREFIX)base
components := $(shell for f in $$(ls -1 images/*/Dockerfile | grep -v '^base'); do basename $$(dirname $$f); done)
images := $(foreach component, $(components), $(PREFIX)$(component))

define tasks
$(foreach image, $(components), $(1)/$(image))
endef

run: env force
	docker compose up

env: images-create .env

images-create: $(call tasks,image-update) force

images-rm: $(call tasks,image-rm) force

images-update: $(call tasks,image-update) force

image-create/$(BASE_IMAGE): force
	docker inspect $(BASE_IMAGE) >/dev/null || docker build -t $(BASE_IMAGE) images/base
image-create/%: image-create/$(BASE_IMAGE) force
	docker inspect $(PREFIX)$* >/dev/null || \
	docker build --build-arg BASE_IMAGE=$(BASE_IMAGE) -t $(PREFIX)$* images/$*

image-rm/%: force
	docker image rm -f $(PREFIX)$* || exit 0

image-update/%: image-rm/% image-create/%
	@echo updated $*

.env:
	echo "PREFIX=$(PREFIX)" > .env

init-kz: force
	docker compose exec kz sup kazoo_apps_maintenance start ecallmgr
	docker compose exec kz sup kazoo_apps_maintenance start konami
	docker compose exec kz sup crossbar_maintenance create_account kazoo kazoo kazoo kazoo || exit 0
	docker compose exec kz sup ecallmgr_maintenance add_fs_node freeswitch@fs-kz.kz

docker-prune: $(call tasks,image-rm) image-rm/base force
	docker compose rm -f -v -s || exit 0
	docker system prune -f || exit 0
	docker system prune -f || exit 0

task/$(PREFIX)%: force
	echo run $*

t: force
	@echo $(components)
	@echo $(images)

force:
