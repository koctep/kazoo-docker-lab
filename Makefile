PREFIX ?= kz-
BASE_IMAGE := $(PREFIX)base
components := $(shell for f in $$(ls -1 */Dockerfile | grep -v '^base'); do dirname $$f; done)
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
	docker inspect $(BASE_IMAGE) >/dev/null || docker build -t $(BASE_IMAGE) base
image-create/%: image-create/$(BASE_IMAGE) force
	docker inspect $(PREFIX)$* >/dev/null || \
	docker build --build-arg BASE_IMAGE=$(BASE_IMAGE) -t $(PREFIX)$* $*

image-rm/%: force
	docker image rm $(PREFIX)$* || exit 0

image-update/%: image-rm/% image-create/%
	@echo updated $*

.env:
	echo "PREFIX=$(PREFIX)" > .env

docker-prune: $(call tasks,image-rm) force
	docker compose rm -f -v -s || exit 0
	docker system prune -f || exit 0

task/$(PREFIX)%: force
	echo run $*

t: force
	@echo $(components)
	@echo $(images)

force:
