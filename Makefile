default: build

build:
	docker build -t flash .

test: build
	docker run --privileged -ti -v $(shell pwd):/code flash npm test

shellcheck: build
	docker run --rm -ti -v $(shell pwd):/code flash shellcheck Darwin/flash Linux/flash

tag:
	git tag ${TAG}
	git push origin ${TAG}
