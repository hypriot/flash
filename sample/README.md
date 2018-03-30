# cloud-init sample config files

Here you can find a collection of sample configurations to improve your
first-boot experience using HypriotOS.

Beginning with HypriotOS 1.7.0 we have switched to [cloud-init](http://cloudinit.readthedocs.io/en/0.7.9/) which gives you much more power to customize your device automatically during the first initial boot.

You can either use our `flash` tool with option `-u` or `--userdata` to specify the YAML file. The flash tool will copy it to the SD card right after flashing.

Otherwise copy the YAML file to the boot partition of the SD card to the `/boot/user-data` file.

Quick installation:

```
$ flash -u your-cloud-init.yml https://github.com/hypriot/image-builder-rpi/releases/download/v1.8.0/hypriotos-rpi-v1.8.0.img.zip
$ ssh pirate@black-pearl.local
```

login with username "pirate", password "hypriot"


## WiFi

Setup WiFi for your Raspberry Pi Zero or Pi 3 / 3 B+.

* [wifi-user-data.yml](./wifi-user-data.yml)
  * insert WiFi SSID
  * adjust your country code

## SSH public key authentication

Setup your device with a different user account, remove default user and password.

* [ssh-pub-key.yml](./ssh-pub-key.yml)
  * adjust user name
  * insert SSH public key

## Static IP address

Setup your eth0 device with a static IP address.

* [static.yml](./static.yml)

## Hands-free Docker projects

Run a container as a service automatically.

* [rainbow.yml](./rainbow.yml)
  * insert SSH public key
  * insert WiFi SSID and preshared key
  * adjust your country code
  * attach Pimoroni Blinkt
  * flash, boot your Pi 3/0 - enjoy!
