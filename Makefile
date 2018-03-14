.PHONY : build, test, shellcheck, tag

default: build

build:
	docker build -t flash .

TMP_DIR ::= $(shell mktemp -d)

ifeq ($(strip $(TMP_DIR)),)
  TMP_DIR="/tmp"
endif

test: build
	docker run --privileged -ti -v $(shell pwd):/code -v $(TMP_DIR):/tmp flash npm test
	rm -rf $(TMP_DIR)

shellcheck:
	docker run --rm -ti -v $(shell pwd):/mnt koalaman/shellcheck -s bash Darwin/flash Linux/flash Linux/*func

tag:
	git tag ${TAG}
	git push origin ${TAG}
