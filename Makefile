CONTAINER   := iframely
HUB_USER    := ${USER}
IMAGE_NAME  := ${HUB_USER}/${CONTAINER}
VERSION     ?= $(shell git describe --tags --always 2>/dev/null || echo latest)
EXPOSEPORT  := 8061
PUBLISHPORT := ${EXPOSEPORT}
HOST        := ::

# Buildx setup
PLATFORMS   := linux/amd64,linux/arm64
BUILDER     := iframely-builder

.PHONY: buildx-setup build build-all push run start shell exec stop rm history clean restart

buildx-setup:
	@if ! docker buildx inspect $(BUILDER) > /dev/null 2>&1; then \
		echo "Creating new buildx builder: $(BUILDER)"; \
		docker buildx create --name $(BUILDER) --use; \
	fi

build: buildx-setup
	docker buildx build \
		--pull \
		--load \
		--tag $(CONTAINER) .
	@echo Image built with tag: $(CONTAINER)

build-all: buildx-setup
	docker buildx build \
		--pull \
		--platform $(PLATFORMS) \
		--tag $(IMAGE_NAME):$(VERSION) \
		--tag $(IMAGE_NAME):latest .
	@echo Multi-arch image built for: $(PLATFORMS)

push: buildx-setup
	docker buildx build \
		--pull \
		--platform $(PLATFORMS) \
		--tag $(IMAGE_NAME):$(VERSION) \
		--tag $(IMAGE_NAME):latest \
		--push .
	@echo Multi-arch image pushed: $(IMAGE_NAME):$(VERSION)

start: run

run:
	docker \
		run \
		--detach \
		--interactive \
		--tty \
		--hostname=${CONTAINER} \
		--name=${CONTAINER} \
		-e NODE_TLS_REJECT_UNAUTHORIZED=0 \
		-e MAX_WORKERS=${MAX_WORKERS} \
		-e MAX_MEMORY=${MAX_MEMORY} \
		-e CACHE_TTL=${CACHE_TTL} \
		-e HOST=${HOST} \
		-p ${PUBLISHPORT}:${EXPOSEPORT} \
		-v ${PWD}/config.local.js:/iframely/config.local.js \
		$(CONTAINER)

shell:
	docker \
		run \
		--rm \
		--interactive \
		--tty \
		--hostname=${CONTAINER} \
		--name=${CONTAINER} \
		-p ${PUBLISHPORT}:${EXPOSEPORT} \
		--entrypoint "/bin/ash" \
		-v ${PWD}/config.local.js:/iframely/config.local.js \
		$(CONTAINER) 

exec:
	docker exec \
		--interactive \
		--tty \
		--rm \
		${CONTAINER} \
		/bin/ash

stop:
	-docker kill ${CONTAINER}
	-docker rm ${CONTAINER}

rm:
	docker \
		rm ${CONTAINER}

history:
	docker \
		history ${CONTAINER}

clean:
	-docker rm $(CONTAINER)
	-docker rmi $(CONTAINER)

restart: stop clean run
