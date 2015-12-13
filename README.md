# flash
Command line script to flash SD card images for the Raspberry Pi.

This script can

* download a compressed SD card from the internet or from S3
* use a local SD card image, either compressed or uncompressed
* wait until a SD card is plugged in
* search for a SD card plugged into your Computer
* show progress bar while flashing (if `pv` is installed)
* copy an optional `occidentalis.txt` file into the boot partition of the SD image
* copy an optional `config.txt` file into the boot partition of the SD image
* optional set the hostname of this SD image
* optional set the WiFi settings as well
* play a little sound after flashing
* unplugs the SD card

At the moment only Mac OS X and Linux is supported.

## Installation

Download the appropriate version for Linux or Mac with this command

```bash
wget https://raw.githubusercontent.com/hypriot/flash/master/$(uname -s)/flash
chmod +x flash
sudo mv flash /usr/local/bin/flash
```

### Install Dependencies

The `flash` script needs optional tools

* `curl` - if you want to flash directly with an HTTP URL
* `aws` - if you want to flash directly from an AWS S3 bucket
* `pv` - to see a progress bar while flashing with the `dd` command

#### Mac

```bash
brew install pv
brew install awscli
```

#### Linux

```bash
sudo apt-get install -y pv curl python-pip
sudo pip install awscli
```

## Usage

```
$ flash --help
usage: flash [options] name-of-rpi.img

Flash a local or remote Raspberry Pi SD card image.

OPTIONS:
   --help|-h      Show this message
   --bootconf|-C  Copy this config file to /boot/config.txt
   --config|-c    Copy this config file to /boot/occidentalis.txt
   --hostname|-n  Set hostname for this SD image
   --ssid|-s      Set WiFi SSID for this SD image
   --password|-p  Set WiFI password for this SD image
```

## How it looks like

This is a complete download and flash cycle with all its steps.

```
$ flash http://downloads.hypriot.com/hypriot-rpi-20151004-132414.img.zip
Downloading http://downloads.hypriot.com/hypriot-rpi-20151004-132414.img.zip ...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  346M  100  346M    0     0  5643k      0  0:01:02  0:01:02 --:--:-- 5366k
Uncompressing /tmp/image.img.zip ...
Archive:  /tmp/image.img.zip
  inflating: /tmp/hypriot-rpi-20151004-132414.img
Use /tmp/hypriot-rpi-20151004-132414.img
No SD card found. Please insert SD card, I'll wait for it...
Filesystem    512-blocks      Used Available Capacity   iused    ifree %iused  Mounted on
/dev/disk1     974700800 863201064 110987736    89% 107964131 13873467   89%   /
devfs                669       669         0   100%      1159        0  100%   /dev
map -hosts             0         0         0   100%         0        0  100%   /net
map auto_home          0         0         0   100%         0        0  100%   /home
/dev/disk2s1      114576     29456     85120    26%       512        0  100%   /Volumes/boot

Is /dev/disk2s1 correct? y
Unmounting disk2 ...
Unmount of all volumes on disk2 was successful
Unmount of all volumes on disk2 was successful
Flashing /tmp/hypriot-rpi-20151004-132414.img to disk2 ...
Password:
 976MiB 0:01:12 [13.4MiB/s] [=============================================>] 100%
0+15625 records in
0+15625 records out
1024000000 bytes transferred in 72.779589 secs (14069879 bytes/sec)
Unmounting and ejecting disk2 ...
Unmount of all volumes on disk2 was successful
Unmount of all volumes on disk2 was successful
Disk /dev/disk2 ejected
🍺  Finished.
```

## occidentalis.txt

The option `--config` could be used to copy a `occidentalis.txt` into the SD image before it is unplugged.

Many kudos to [Adafruit's occi](https://github.com/adafruit/Adafruit-Occi) package that handles updating hostname and WiFi settings while booting the Raspberry Pi.

The config file `occidentalis.txt` should look like

```
# hostname for your Hypriot Raspberry Pi:
hostname=hypriot-pi

# basic wireless networking options:
wifi_ssid=SSID
wifi_password=12345
```

## config.txt

The option `--bootconf` can be used to copy a `config.txt` into the SD image before it is unplugged.

With this option it is possible to change some memory, camera, video settings etc. See the [config.txt documentation ](https://www.raspberrypi.org/documentation/configuration/config-txt.md) at raspberrypi.org for more details.

The boot config file config.txt has name/value pairs such as:

```
max_usb_current=1
hdmi_force_hotplug=1
```

## Use cases

### Flash a compressed SD image from the internet

```bash
flash http://downloads.hypriot.com/hypriot-rpi-20151004-132414.img.zip
```

### Flash a compressed SD image from S3 bucket

```bash
flash s3://bucket/path/to/hypriot-rpi-20150611-195657.img.zip
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

### Makefile usage

###### Everything from here on is a repeat of above using the makefile instead for repeatability

First stick the SDCARD in use `dmesg` to ensure that it is `/dev/mmcblk0` you’ll see some lines like the following in the dmesg

```
[13943.322789] mmcblk0: mmc0:e624 SU16G 14.8 GiB 
[13943.331703]  mmcblk0: p1 p2
[14383.049094]  mmcblk0: p1 p2
```
Now flash your master node, you will be prompted for details

```
make master
```

Then make a subordinate node, repeat giving unique node names for each node

```
make node
```

Alternatively make a wifi enabled node, giving wifi details as prompted for them

```
make wifi
```

Power the nodes on and you should be able to key the master node with, the password will be ‘hypriot’

```
make key
```

Now enter and change the password with the `passwd` utility

```
make enter
```

then raise the ui
```
make ui
```

Gaze upon all the wonderment

```
make show
```

This last one requires your BROWSER environmanet variables to be set, something like this in `.bashrc` or similar for your shell of choice

```
export BROWSER=chromium
```

Now create the overlay

```
make overlay
```

And test the overlay

```
make overlay-test
```

you should now be able to create more containers at will and they will distribute among your cluster

