.PHONY : build, test, shellcheck, tag

default: build

build:
	docker build -t flash .

TMP_DIR ::= $(shell mktemp -d)

test: build
	docker run --privileged -ti -v $(shell pwd):/code -v $(TMP_DIR):/tmp flash npm test
	rm -rf $(TMP_DIR)

shellcheck: build
	docker run --rm -ti -v $(shell pwd):/code flash shellcheck Darwin/flash Linux/flash

tag:
	git tag ${TAG}
	git push origin ${TAG}
