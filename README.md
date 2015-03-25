# flash
Command line script to flash SD card images for the Raspberry Pi.

This script can

* download a compressed SD card from the internet or from S3
* use a local SD card image, either compressed or uncompressed
* wait until a SD card is plugged in
* search for a SD card plugged into your Computer
* show progress bar while flashing (if `pv` is installed)
* copy a optional `occidentalis.txt` file into the boot partition of the SD image
* optional set the hostname of this SD image
* optional set the WiFi settings as well
* play a little sound after flashing
* unplugs the SD card

At the moment only Mac OSX is supported.

## Usage

```
$ flash --help
usage: flash [options] name-of-rpi.img

Flash a local or remote Raspberry Pi SD card image.

OPTIONS:
   --help|-h      Show this message
   --config|-c    Copy this config file to /boot/occidentalis.txt
   --hostname|-n  Set hostname for this SD image
   --ssid|-s      Set WiFi SSID for this SD image
   --password|-p  Set WiFI password for this SD image
```

## occidentalis.txt

The option `--config` could be used to copy a `occidentalis.txt` into the SD image bef
The config file `occidentalis.txt` should look like

```
# hostname for your Hypriot Raspberry Pi:
hostname = hypriot-pi

# basic wireless networking options:
wifi_ssid = SSID
wifi_password = 12345
```

## Use cases

### Flash a compressed SD image from the internet

```bash
flash http://assets.hypriot.com/hypriot-rpi-20150301-140537.img.zip
```

### Flash with a given hostname

This works only for SD card images that already have `occi` installed.

```bash
flash --hostname mypi hypriot.img
```

Then unplug the SD card from your computer, plug it into your Pi and boot your Pi. After a while the Pi can be found via Bonjour/avahi and you can log in with

```bash
ssh pi@mypi.local
```
