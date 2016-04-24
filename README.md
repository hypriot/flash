# flash

Command line script to flash SD card images for the Raspberry Pi.

The typical workflow looks like this:

[![asciicast](https://asciinema.org/a/4k72pounxxybtix84ecl4b69w.png)](https://asciinema.org/a/4k72pounxxybtix84ecl4b69w)

1.  Run `flash http://downloads.hypriot.com/hypriot-rpi-20151115-132854.img.zip`
2.  Insert SD card to your notebook
3.  Press RETURN
4.  Eject SD card and insert it to your Raspberry Pi - done!

This script can

*   download a compressed SD card from the internet or from S3
*   use a local SD card image, either compressed or uncompressed
*   wait until a SD card is plugged in
*   search for a SD card plugged into your Computer
*   show progress bar while flashing (if `pv` is installed)
*   copy an optional `device-init.yaml` or `occidentalis.txt` file into the boot partition of the SD
*   copy an optional `config.txt` file into the boot partition of the SD image
*   optional set the hostname of this SD image
*   optional set the WiFi settings as well
*   play a little sound after flashing
*   unplugs the SD card

At the moment only Mac OS X and Linux is supported.

## Installation

For the Mac you will have to install `wget` first

```bash
brew install wget
```

Download the appropriate version for Linux or Mac with this command

```bash
wget https://raw.githubusercontent.com/hypriot/flash/master/$(uname -s)/flash
chmod +x flash
sudo mv flash /usr/local/bin/flash
```

### Install Dependencies

The `flash` script needs optional tools

*   `curl` - if you want to flash directly with an HTTP URL
*   `aws` - if you want to flash directly from an AWS S3 bucket
*   `pv` - to see a progress bar while flashing with the `dd` command
*   `unzip` - to extract zip files.

#### Mac

```bash
brew install pv
brew install awscli
```

#### Linux

```bash
sudo apt-get install -y pv curl python-pip unzip
sudo pip install awscli
```

## Usage

```bash
$ flash --help
usage: flash [options] name-of-rpi.img

Flash a local or remote Raspberry Pi SD card image.

OPTIONS:
   --help|-h      Show this message
   --bootconf|-C  Copy this config file to /boot/config.txt
   --config|-c    Copy this config file to /boot/device-init.yaml (or occidentalis.txt)
   --hostname|-n  Set hostname for this SD image
   --ssid|-s      Set WiFi SSID for this SD image
   --password|-p  Set WiFI password for this SD image
```

## How it looks like

This is a complete download and flash cycle with all its steps.

```shell
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

## device-init.yaml

The option `--config` could be used to copy a `device-init.yaml` into the SD
image before it is unplugged. This YAML file can be read by newer HyperiotOS
SD images.

The config file device-init.yaml should look like

```yaml
hostname: black-pearl
wifi:
  interfaces:
    wlan0:
      ssid: "MyNetwork"
      password: "secret_password"
```

If you don't want to set any wifi settings, comment out or remove the wlan0, ssid and password.

## occidentalis.txt

**WARNING** The following option will change in the near future as we are
switching from our RPi-only SD card image to new debian based SD images for
different devices. To support all other devices there will be a different file
to do similar tasks and we have more functions in mind.

The option `--config` could be used to copy a `occidentalis.txt` into the SD
image before it is unplugged.

Many kudos to [Adafruit's occi](https://github.com/adafruit/Adafruit-Occi)
package that handles updating hostname and WiFi settings while booting the
Raspberry Pi.

The config file `occidentalis.txt` should look like

```bash
# hostname for your Hypriot Raspberry Pi:
hostname=hypriot-pi

# basic wireless networking options:
wifi_ssid=SSID
wifi_password=12345
```

## config.txt

The option `--bootconf` can be used to copy a `config.txt` into the SD image
before it is unplugged.

With this option it is possible to change some memory, camera, video settings
etc. See the [config.txt documentation](https://www.raspberrypi.org/documentation/configuration/config-txt.md)
at raspberrypi.org for more details.

The boot config file config.txt has name/value pairs such as:

```bash
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

Then unplug the SD card from your computer, plug it into your Pi and boot your
Pi. After a while the Pi can be found via Bonjour/avahi and you can log in with

```bash
ssh pi@mypi.local
```

## Development

Pull requests and other feedback is always welcome. The `flash` tool should fit
our all needs and environments.

### Test Linux from Mac

As I only have a MacBookPro where I started to develop the `flash` tool it is
hard for me to test Linux issues. But with some help I found a way to spin up a
VirtualBox Vagrant box with Ubuntu that maps the internal Apple SD card reader
into the VM. Thanks to [Flexshot](https://github.com/Flexshot) for the helper
functions I found in [NextThingCo/CHIP-SDK#15](https://github.com/NextThingCo/CHIP-SDK/pull/15).

Check the vendor ID and product ID in "About this Mac" -> System Report ... ->
Card Reader. I found the vendor ID 0x05ac and product ID 0x8406 can be found in
the `Vagrantfile`.

```bash
vagrant up --provider virtualbox
```
