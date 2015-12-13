.PHONY: all help flash node

user = $(shell whoami)
ifeq ($(user),root)
$(error  "do not run as root! run 'gpasswd -a USER docker' on the user of your choice")
endif

all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make node       - flash a new sd card for the cluster

node: hypriot NODE_NAME IMG DEVICE flash rm_node_name

wifi: hypriot WIFI_NETWORK WIFI_NETWORK_PASSWORD NODE_NAME IMG DEVICE flash rm_node_name

flash:
	sudo ./flash --hostname `cat NODE_NAME` --device `cat DEVICE` `cat IMG`

wififlash:
	sudo ./flash --ssid `cat WIFI_NETWORK` --password `cat WIFI_NETWORK_PASSWORD` --hostname `cat NODE_NAME` --device `cat DEVICE` `cat IMG`

NODE_NAME:
	@while [ -z "$$NODE_NAME" ]; do \
		read -r -p "Enter the node name you wish to associate with this card [NODE_NAME]: " NODE_NAME; echo "$$NODE_NAME">>NODE_NAME; cat NODE_NAME; \
	done ;

rm_node_name:
	rm NODE_NAME

hypriot: hypriot-rpi-20151128-152209-docker-swarm-cluster.img.zip

hypriot-rpi-20151128-152209-docker-swarm-cluster.img.zip:
	wget -c https://downloads.hypriot.com/hypriot-rpi-20151128-152209-docker-swarm-cluster.img.zip

IMG:
	@while [ -z "$$IMG" ]; do \
		read -r -p "Enter the full path to the hypriot image you wish to associate with this  [IMG]: " IMG; echo "$$IMG">>IMG; cat IMG; \
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
