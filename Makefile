.PHONY : build, test, shellcheck, tag

default: build

build:
	docker build -t flash .

TMP_DIR ::= $(shell mktemp -d)
TMP_DIR ?= "/tmp/hypriot-flash"

test: build
	mkdir -p $(TMP_DIR)
	docker run --privileged -ti -v $(shell pwd):/code -v $(TMP_DIR):/tmp flash npm test
	rm -rf $(TMP_DIR)

shellcheck:
	docker run --rm -ti -v $(shell pwd):/mnt -w /mnt koalaman/shellcheck -s bash flash

tag:
	git tag ${TAG}
	git push origin ${TAG}
