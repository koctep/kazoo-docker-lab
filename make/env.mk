ifeq ($(ADD_HOSTS),)
docker = docker compose
else
docker = docker compose -f compose.yaml -f .env.yaml
ADD_YAML = .env.yaml
endif

.env:
	echo "ROOT_DIR=$(PWD)" > .env
	echo "PROJECT=$(PROJECT)" >> .env
	echo "UID=$(shell id -u)" >> .env
	echo "GID=$(shell id -g)" >> .env
	echo "ADD_HOSTS=$(ADD_HOSTS)" >> .env

.env.yaml: .env
	[ ! -z "$(ADD_HOSTS)" ] && echo "services:" > $@ || exit 0
	for h in $(ADD_HOSTS); do \
		echo "  $$h:" >> $@; \
		echo "    extends:" >> $@; \
		echo "      file: ${ROOT_DIR}/src/roles/kazoo-apps.yaml" >> $@; \
		echo "      service: role-kazoo-apps" >> $@; \
		echo "    hostname: $$h.kz" >> $@; \
	done

env: images-create .env $(ADD_YAML)
	$(docker) create

init: start force
	$(MAKE) wait-for-regs
	$(MAKE) stop

rm: force
	$(docker) stop || exit 0
	$(docker) rm -f || exit 0
	rm -f .env .env.yaml

run: env force
	$(docker) up

start: env force
	$(docker) start

create: env force

stop: force
	$(docker) stop

ps: force
	$(docker) ps

reinit: force
	docker compose stop kz couchdb || exit 0
	docker compose rm -f couchdb || exit 0
	docker compose create couchdb kz
	docker compose start couchdb kz
