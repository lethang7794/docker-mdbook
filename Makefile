DOCKER_CLI_EXPERIMENTAL := enabled
DOCKER_BUILDKIT := 1

DOCKER_USERNAME := lethang7794
DOCKER_IMAGE_NAME := mdbook

BASE_IMAGE_MINIMAL := alpine:3.20
BASE_IMAGE_RUST := rust:alpine3.20

DOCKER_HUB_BASE_NAME := ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}
DOCKER_BASE_NAME := ghcr.io/${DOCKER_HUB_BASE_NAME}
DOCKER_VERSION := $(shell cat ./deps/Cargo.toml | grep 'mdbook = ' | awk '{print $$3}' | tr -d '"')
MDBOOK_MERMAID_VERSION := $(shell cat ./deps/Cargo.toml | grep 'mdbook-mermaid = ' | awk '{print $$3}' | tr -d '"')
MDBOOK_TOC_VERSION := $(shell cat ./deps/Cargo.toml | grep 'mdbook-toc = ' | awk '{print $$3}' | tr -d '"')
MDBOOK_ADMONISH_VERSION := $(shell cat ./deps/Cargo.toml | grep 'mdbook-admonish = ' | awk '{print $$3}' | tr -d '"')
MDBOOK_ALERTS_VERSION := $(shell cat ./deps/Cargo.toml | grep 'mdbook-alerts = ' | awk '{print $$3}' | tr -d '"')
MDBOOK_PAGETOC_VERSION := $(shell cat ./deps/Cargo.toml | grep 'mdbook-pagetoc = ' | awk '{print $$3}' | tr -d '"')
MDBOOK_YML_HEADER_VERSION := $(shell cat ./deps/Cargo.toml | grep 'mdbook-yml-header = ' | awk '{print $$3}' | tr -d '"')
DOCKER_TAG := v${DOCKER_VERSION}
GITHUB_REF_NAME ?= local
DOCKER_SCOPE := mdbook-${GITHUB_REF_NAME}
DOCKER_OUTPUT_TYPE ?= docker
ifeq ($(IS_PULL_REQUEST), false)
	DOCKER_OUTPUT_TYPE := registry
endif
PKG_NAME := ${DOCKER_BASE_NAME}:${DOCKER_TAG}
HUB_NAME := ${DOCKER_HUB_BASE_NAME}:${DOCKER_TAG}
PKG_LATEST := ${DOCKER_BASE_NAME}:latest
HUB_LATEST := ${DOCKER_HUB_BASE_NAME}:latest

ARCH := $(shell uname -m)
ifeq ($(ARCH), x86_64)
	PLATFORM := amd64
	CARGO_TARGET := x86_64-unknown-linux-musl
else ifeq ($(ARCH), arm64)
	PLATFORM := arm64
	CARGO_TARGET := aarch64-unknown-linux-musl
else ifeq ($(ARCH), aarch64)
	PLATFORM := arm64
	CARGO_TARGET := aarch64-unknown-linux-musl
endif

.PHONY: login-dockerhub
login-dockerhub:
	echo "${DOCKER_HUB_TOKEN}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

.PHONY: login-ghcr
login-ghcr:
	echo "${GITHUB_TOKEN}" | docker login ghcr.io -u "${DOCKER_USERNAME}" --password-stdin

.PHONY: login
login: login-dockerhub login-ghcr

.PHONY: setup-buildx
setup-buildx:
	docker buildx create --use --driver docker-container
	docker buildx inspect --bootstrap
	docker version

.PHONY: build
build: build-alpine build-rust

.PHONY: build-alpine
build-alpine:
	docker buildx build . \
		--tag "${HUB_NAME}-$(PLATFORM)" \
		--output "type=${DOCKER_OUTPUT_TYPE}" \
		--cache-from "type=gha,scope=${DOCKER_SCOPE}" \
		--cache-to "type=gha,mode=max,scope=${DOCKER_SCOPE}" \
		--build-arg MDBOOK_VERSION="${DOCKER_VERSION}" \
		--build-arg BASE_IMAGE="${BASE_IMAGE_MINIMAL}" \
		--build-arg MDBOOK_MERMAID_VERSION="${MDBOOK_MERMAID_VERSION}" \
		--build-arg MDBOOK_TOC_VERSION="${MDBOOK_TOC_VERSION}" \
		--build-arg MDBOOK_ADMONISH_VERSION="${MDBOOK_ADMONISH_VERSION}" \
		--build-arg MDBOOK_ALERTS_VERSION="${MDBOOK_ALERTS_VERSION}" \
		--build-arg MDBOOK_PAGETOC_VERSION="${MDBOOK_PAGETOC_VERSION}" \
		--build-arg MDBOOK_YML_HEADER_VERSION="${MDBOOK_YML_HEADER_VERSION}" \
		--build-arg CARGO_TARGET="${CARGO_TARGET}"

.PHONY: build-rust
build-rust:
	docker buildx build . \
		--tag "${HUB_NAME}-rust-$(PLATFORM)" \
		--output "type=${DOCKER_OUTPUT_TYPE}" \
		--cache-from "type=gha,scope=${DOCKER_SCOPE}" \
		--cache-to "type=gha,mode=max,scope=${DOCKER_SCOPE}" \
		--build-arg MDBOOK_VERSION="${DOCKER_VERSION}" \
		--build-arg BASE_IMAGE="${BASE_IMAGE_RUST}" \
		--build-arg MDBOOK_MERMAID_VERSION="${MDBOOK_MERMAID_VERSION}" \
		--build-arg MDBOOK_TOC_VERSION="${MDBOOK_TOC_VERSION}" \
		--build-arg MDBOOK_ADMONISH_VERSION="${MDBOOK_ADMONISH_VERSION}" \
		--build-arg MDBOOK_ALERTS_VERSION="${MDBOOK_ALERTS_VERSION}" \
		--build-arg MDBOOK_PAGETOC_VERSION="${MDBOOK_PAGETOC_VERSION}" \
		--build-arg MDBOOK_YML_HEADER_VERSION="${MDBOOK_YML_HEADER_VERSION}" \
		--build-arg CARGO_TARGET="${CARGO_TARGET}"

.PHONY: merge
merge:
	docker buildx imagetools create --tag "${PKG_NAME}-rust" "${HUB_NAME}-rust-amd64" "${HUB_NAME}-rust-amd64"
	docker buildx imagetools create --tag "${HUB_NAME}-rust" "${HUB_NAME}-rust-amd64" "${HUB_NAME}-rust-amd64"
	docker buildx imagetools create --tag "${PKG_NAME}" "${HUB_NAME}-amd64" "${HUB_NAME}-amd64"
	docker buildx imagetools create --tag "${HUB_NAME}" "${HUB_NAME}-amd64" "${HUB_NAME}-amd64"
	
	docker buildx imagetools create --tag "${PKG_LATEST}-rust" "${HUB_NAME}-rust-amd64" "${HUB_NAME}-rust-amd64"
	docker buildx imagetools create --tag "${HUB_LATEST}-rust" "${HUB_NAME}-rust-amd64" "${HUB_NAME}-rust-amd64"
	docker buildx imagetools create --tag "${PKG_LATEST}" "${HUB_NAME}-amd64" "${HUB_NAME}-amd64"
	docker buildx imagetools create --tag "${HUB_LATEST}" "${HUB_NAME}-amd64" "${HUB_NAME}-amd64"

.PHONY: test
test:
	@docker run --rm "${HUB_NAME}-$(PLATFORM)" mdbook --version
	@docker run --rm "${HUB_NAME}-rust-$(PLATFORM)" mdbook --version

.PHONY: test-build
test-build:
	docker run --rm -v "./example:/app" "${HUB_NAME}-$(PLATFORM)" mdbook build
	docker run --rm -v "./example:/app" --entrypoint sh "${HUB_NAME}-$(PLATFORM)" -c 'mdbook-admonish --version'
	docker run --rm -v "./example:/app" --entrypoint sh "${HUB_NAME}-$(PLATFORM)" -c 'mdbook-alerts --version'
	docker run --rm -v "./example:/app" --entrypoint sh "${HUB_NAME}-$(PLATFORM)" -c 'mdbook-pagetoc --help'
	docker run --rm -v "./example:/app" --entrypoint sh "${HUB_NAME}-$(PLATFORM)" -c 'mdbook-yml-header --help'

.PHONY: test-build-with-latest
test-build-with-latest:
	docker run --rm -v "./example:/app" "${HUB_LATEST}" mdbook build
	docker run --rm -v "./example:/app" --entrypoint sh "${HUB_LATEST}" -c 'mdbook-admonish --version'
	docker run --rm -v "./example:/app" --entrypoint sh "${HUB_NAME}-$(PLATFORM)" -c 'mdbook-alerts --version'
	docker run --rm -v "./example:/app" --entrypoint sh "${HUB_NAME}-$(PLATFORM)" -c 'mdbook-pagetoc --help'
	docker run --rm -v "./example:/app" --entrypoint sh "${HUB_NAME}-$(PLATFORM)" -c 'mdbook-yml-header --help'

.PHONY: run
run:
	docker run --rm -i -t -v "./example:/app" -p "3000:3000" -p "3001:3001" --entrypoint sh "${HUB_NAME}-$(PLATFORM)"

.PHONY: compose-build
compose-build:
	cd ./example && \
	docker compose run --rm mdbook-service mdbook build && \
	docker compose run --rm --entrypoint sh mdbook-service -c 'mdbook-admonish install /app'

.PHONY: compose-serve
compose-serve:
	cd ./example && \
	docker compose up
