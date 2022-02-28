SHELL=/bin/bash
TMP_DIR:=$(shell mktemp -d)
TMP_DIR?="/tmp/hypriot-flash"

default: build

.PHONY: build
build:
	docker build -t flash .

.PHONY: test
test: build
	mkdir -p $(TMP_DIR)
	docker run --privileged -ti -v $(shell pwd):/code -v $(TMP_DIR):/tmp -e CIRCLE_TAG flash npm test
	rm -rf $(TMP_DIR)

.PHONY: install
install:
	( \
		VERSION=$(shell curl -s https://api.github.com/repos/hypriot/flash/releases/latest | grep tag_name | cut -d\" -f4); \
		curl -L https://github.com/hypriot/flash/releases/download/$$VERSION/flash >flash-$$VERSION; \
		chmod +x flash-$$VERSION; \
		sudo mv flash-$$VERSION /usr/local/bin/flash; \
	)

.PHONY: shellcheck
shellcheck:
	docker run --rm -ti -v $(shell pwd):/mnt -w /mnt koalaman/shellcheck -s bash flash

.PHONY: tag
tag:
	git tag ${TAG}
	git push origin ${TAG}
