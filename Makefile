.PHONY: login build build-push update-latest

# # build or empty
TAG_PREFIX := $(VARIANT:run%=%)

# build or empty or build-version or -version
WITH_VERSION := $(if $(TRAVIS_TAG),$(TAG_PREFIX)-$(TRAVIS_TAG),$(TAG_PREFIX))

# build or empty or build-version or version
IMAGE_TAG_WITHOUT_HYPHEN := $(WITH_VERSION:-%=%)

IMAGE_TAG := $(if $(IMAGE_TAG_WITHOUT_HYPHEN),:$(IMAGE_TAG_WITHOUT_HYPHEN),$(IMAGE_TAG_WITHOUT_HYPHEN))

IMAGE := $(REPO)/$(RUNTIME)$(IMAGE_TAG)

DIR := $(RUNTIME)$(if $(VARIANT),/$(VARIANT))

check-runtime-env:
ifndef RUNTIME
	$(error RUNTIME is undefined)
endif

check-variant-env:
ifndef VARIANT
	$(error VARIANT is undefined)
endif

check-repo-env:
ifndef REPO
	$(error REPO is undefined)
endif

check-tag:
ifndef TRAVIS_TAG
	$(error TRAVIS_TAG is undefined)
endif

login:
	echo "$$DOCKER_PASS" | docker login -u $$DOCKER_USER --password-stdin

build: check-runtime-env check-variant-env check-repo-env check-tag
	cd $(DIR) && \
	docker build -t "$(IMAGE)" .

build-push: build login 
	docker push $(IMAGE)

update-latest: check-runtime-env check-variant-env check-repo-env login 
	LATEST=$(shell (head -n 1 LATEST)) && \
	docker pull $$REPO/$${RUNTIME}:$$LATEST && \
	docker tag $$REPO/$${RUNTIME}:$$LATEST $$REPO/$${RUNTIME}:latest && \
	docker push $$REPO/$${RUNTIME}:latest	
