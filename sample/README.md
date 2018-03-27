# flash sample configs

Here you can find a collection of sample configurations to improve your
first-boot experience using HypriotOS.

Beginning with HypriotOS 1.7.0 we have switched to [cloud-init]() which gives you much more power to customize your device automatically during the first initial boot.

## WiFi

Setup WiFi for your Raspberry Pi Zero or Pi 3 / 3 B+.

* [wifi-user-data.yml](./wifi-user-data.yml)
  * insert WiFi SSID

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
  * attach Pimoroni Blinkt
  * flash, boot your Pi 3/0 - enjoy!
