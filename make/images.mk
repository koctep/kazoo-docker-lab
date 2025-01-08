BASE_IMAGE := $(PROJECT)-base
components := $(shell for f in $$(ls -1 src/images/*/Dockerfile | grep -v '^base'); do basename $$(dirname $$f); done)
images := $(foreach component, $(components), $(PROJECT)-$(component))

define tasks
$(foreach image, $(components), $(1)/$(image))
endef

images-create: $(call tasks,image-update) force

images-rm: $(call tasks,image-rm) force

images-update: $(call tasks,image-update) force

image-create/$(BASE_IMAGE): force
	docker inspect $(BASE_IMAGE) >/dev/null || docker build -t $(BASE_IMAGE) src/images/base
image-create/%: image-create/$(BASE_IMAGE) force
	docker inspect $(PROJECT)-$* >/dev/null || \
	docker build --build-arg BASE_IMAGE=$(BASE_IMAGE) -t $(PROJECT)-$* src/images/$*

image-rm/%: force
	docker image rm -f $(PROJECT)-$* || exit 0

image-update/%: image-rm/% image-create/%
	@echo updated $*
