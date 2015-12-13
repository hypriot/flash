.PHONY: all help flash node

user = $(shell whoami)
ifeq ($(user),root)
$(error  "do not run as root! run 'gpasswd -a USER sudo' on the user of your choice")
endif

all: help

help:
	@echo 'http://blog.hypriot.com/post/introducing-hypriot-cluster-lab-docker-clustering-as-easy-as-it-gets/'
	@echo 'this is a recipe making the above docker cluster with overlay network'
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make master       - flash a new master sd card for the cluster
	@echo ""   2. make node       - flash a new sd card for the cluster

master: hypriot CL_MASTER_NAME cp_master_name add_node_name IMG DEVICE flashmaster

node: rm_node_name hypriot NODE_NAME add_node_name IMG DEVICE flash

wifi: hypriot WIFI_NETWORK WIFI_NETWORK_PASSWORD NODE_NAME IMG DEVICE wififlash rm_node_name

ui: dockerui

dockerui:  CL_MASTER CL_MASTER_NAME dockeruipull

ps: CL_MASTER dockerps

info: CL_MASTER dockerinfo

enter: CL_MASTER entermaster

key: CL_MASTER keymaster

show: ps browser

overlay: MY_NET CL_MASTER mkoverlay dockernetworkls

overlay-test: overlay serveindex wgetindex

flash:
	sudo ./flash --hostname `cat NODE_NAME` --device `cat DEVICE` `cat IMG`
	date -I>master

flashmaster:
	sudo ./flash --hostname `cat CL_MASTER_NAME` --device `cat DEVICE` `cat IMG`

wififlash:
	sudo ./flash --ssid `cat WIFI_NETWORK` --password `cat WIFI_NETWORK_PASSWORD` --hostname `cat NODE_NAME` --device `cat DEVICE` `cat IMG`

browser:
	$(eval CL_MASTER := $(shell cat CL_MASTER))
	$$BROWSER http://$(CL_MASTER):8500
	$$BROWSER http://$(CL_MASTER):9000

keymaster:
	$(eval CL_MASTER := $(shell cat CL_MASTER))
	ssh-copy-id root@$(CL_MASTER)
	echo ping
	ssh root@$(CL_MASTER) 'echo pong'
	@ssh root@$(CL_MASTER) 'echo pong, congratulations you successfully keyed your master'

serveindex:
	$(eval CL_MASTER := $(shell cat CL_MASTER))
	$(eval MY_NET := $(shell cat MY_NET))
	$(eval NODE_NAME := $(shell cat NODE_NAME))
	docker -H $(CL_MASTER):2378 run  --cidfile=serveindex -itd --name=webserver --net=$(MY_NET) --env="constraint:node==$(NODE_NAME)" hypriot/rpi-nano-httpd

wgetindex:
	$(eval CL_MASTER := $(shell cat CL_MASTER))
	$(eval MY_NET := $(shell cat MY_NET))
	$(eval NODE2_NAME := $(shell cat NODE2_NAME))
	docker -H $(CL_MASTER):2378 run -it --rm --net=$(MY_NET) --env="contraint:node==$(NODE2_NAME)" hypriot/armhf-busybox wget -O- http://webserver/index.html

entermaster:
	$(eval CL_MASTER := $(shell cat CL_MASTER))
	ssh root@$(CL_MASTER)

mkoverlay:
	$(eval CL_MASTER := $(shell cat CL_MASTER))
	docker -H $(CL_MASTER):2378 network create -d overlay `cat MY_NET`
	date -I>mkoverlay

dockernetworkls:
	$(eval CL_MASTER := $(shell cat CL_MASTER))
	docker -H $(CL_MASTER):2378 network ls

dockerinfo:
	$(eval CL_MASTER := $(shell cat CL_MASTER))
	docker -H $(CL_MASTER):2378 info

dockerps:
	$(eval CL_MASTER := $(shell cat CL_MASTER))
	docker -H $(CL_MASTER):2378 ps

dockeruipull:
	$(eval CL_MASTER := $(shell cat CL_MASTER))
	$(eval CL_MASTER_NAME := $(shell cat CL_MASTER_NAME))
	docker -H $(CL_MASTER):2378 run -d -p 9000:9000 --env="constraint:node==$(CL_MASTER_NAME)" --name dockerui hypriot/rpi-dockerui -e http://$(CL_MASTER):2378

rm_node_name:
	rm NODE2_NAME
	mv NODE_NAME NODE2_NAME

cp_master_name:
	cp CP_MASTER_NAME NODE_NAME

add_node_name:
	cat NODE_NAME>>NODE_NAMES

# Download the image

hypriot: hypriot-rpi-20151128-152209-docker-swarm-cluster.img.zip

hypriot-rpi-20151128-152209-docker-swarm-cluster.img.zip:
	wget -c https://downloads.hypriot.com/hypriot-rpi-20151128-152209-docker-swarm-cluster.img.zip

# This section is all about setting some values that we don't want to commit, so each should also be in .gitignore

NODE_NAME:
	@while [ -z "$$NODE_NAME" ]; do \
		read -r -p "Enter the node name you wish to associate with this card [NODE_NAME]: " NODE_NAME; echo "$$NODE_NAME">>NODE_NAME; cat NODE_NAME; \
	done ;

IMG:
	@while [ -z "$$IMG" ]; do \
		read -r -p "Enter the full path to the hypriot image you wish to associate with this  [IMG]: " IMG; echo "$$IMG">>IMG; cat IMG; \
	done ;

CL_MASTER:
	@while [ -z "$$CL_MASTER" ]; do \
		read -r -p "Enter the address of the CL_MASTER [192.168.223.1]: " CL_MASTER; echo "$$CL_MASTER">>CL_MASTER; cat CL_MASTER; \
	done ;

CL_MASTER_NAME:
	@while [ -z "$$CL_MASTER_NAME" ]; do \
		read -r -p "Enter the name of the CL_MASTER_NAME [cl-master]: " CL_MASTER_NAME; echo "$$CL_MASTER_NAME">>CL_MASTER_NAME; cat CL_MASTER_NAME; \
	done ;

DEVICE:
	@while [ -z "$$DEVICE" ]; do \
		read -r -p "Enter the path to the SD card device [i.e. usually /dev/mmcblk0] you wish to associate with this card [DEVICE]: " DEVICE; echo "$$DEVICE">>DEVICE; cat DEVICE; \
	done ;

WIFI_NETWORK:
	@while [ -z "$$WIFI_NETWORK" ]; do \
		read -r -p "Enter the wifi network to associate with this card [WIFI_NETWORK]: " WIFI_NETWORK; echo "$$WIFI_NETWORK">>WIFI_NETWORK; cat WIFI_NETWORK; \
	done ;

WIFI_NETWORK_PASSWORD:
	@while [ -z "$$WIFI_NETWORK_PASSWORD" ]; do \
		read -r -p "Enter the password of the WIFI_NETWORK with this card [WIFI_NETWORK_PASSWORD]: " WIFI_NETWORK_PASSWORD; echo "$$WIFI_NETWORK_PASSWORD">>WIFI_NETWORK_PASSWORD; cat WIFI_NETWORK_PASSWORD; \
	done ;

MY_NET:
	@while [ -z "$$MY_NET" ]; do \
		read -r -p "Enter the network name of the overlay network[my-net]: " MY_NET; echo "$$MY_NET">>MY_NET; cat MY_NET; \
	done ;

