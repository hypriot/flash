# flash

[![CircleCI](https://circleci.com/gh/hypriot/flash.svg?style=svg)](https://circleci.com/gh/hypriot/flash)
[![Build Status](https://travis-ci.org/hypriot/flash.svg?branch=master)](https://travis-ci.org/hypriot/flash)
[![Release](https://img.shields.io/github/release/hypriot/flash.svg)](https://github.com/hypriot/flash#installation)
[![Stars](	https://img.shields.io/github/stars/hypriot/flash.svg?style=social&label=Stars)](https://github.com/hypriot/flash#installation)

Command line script to flash SD card images of any kind.

Note that for some devices (e.g. Raspberry Pi), at the end of the flashing process the tool tries to customize the SD card e.g. it configures a hostname or WiFi. And with a cloud-init enabled image you can do much more like adding users, SSH keys etc.

The typical workflow looks like this:

[![asciicast](https://asciinema.org/a/4k72pounxxybtix84ecl4b69w.png)](https://asciinema.org/a/4k72pounxxybtix84ecl4b69w)

1. Run `flash https://github.com/hypriot/image-builder-rpi/releases/download/v1.7.1/hypriotos-rpi-v1.7.1.img.zip`
2. Insert SD card to your notebook
3. Press RETURN
4. Eject SD card and insert it to your Raspberry Pi - done!

This script can

* download a compressed SD card from the internet or from S3
* use a local SD card image, either compressed or uncompressed
* wait until a SD card is plugged in
* search for a SD card plugged into your Computer
* show progress bar while flashing (if `pv` is installed)
* copy an optional cloud-init `user-data` and `meta-data` file into the boot partition of the SD image
* copy an optional `config.txt` file into the boot partition of the SD image (eg. to enable onboard WiFi)
* copy an optional `device-init.yaml` or `occidentalis.txt` file into the boot partition of the SD image (for older HypriotOS versions)
* optional set the hostname of this SD image
* optional set the WiFi settings as well
* play a little sound after flashing
* unplugs the SD card

At the moment only Mac OS X and Linux is supported.

## Installation

Download the appropriate version for Linux or Mac with this command

```bash
curl -O https://raw.githubusercontent.com/hypriot/flash/master/flash
chmod +x flash
sudo mv flash /usr/local/bin/flash
```

### Install Dependencies

The `flash` script needs optional tools

* `curl` - if you want to flash directly with an HTTP URL
* `aws` - if you want to flash directly from an AWS S3 bucket
* `pv` - to see a progress bar while flashing with the `dd` command
* `unzip` - to extract zip files.
* `hdparm` - to run the program

#### Mac

```bash
brew install pv
brew install awscli
```

#### Linux (Debian/Ubuntu)

```bash
sudo apt-get install -y pv curl python-pip unzip hdparm
sudo pip install awscli
```

## Usage

```bash
$ flash --help
usage: flash [options] [name-of-rpi.img]

Flash a local or remote Raspberry Pi SD card image.

OPTIONS:
   --help|-h      Show this message
   --bootconf|-C  Copy this config file to /boot/config.txt
   --config|-c    Copy this config file to /boot/device-init.yaml (or occidentalis.txt)
   --hostname|-n  Set hostname for this SD image
   --ssid|-s      Set WiFi SSID for this SD image
   --password|-p  Set WiFI password for this SD image
   --clusterlab|-l Start Cluster-Lab on boot: true or false
   --device|-d    Card device to flash to (e.g. /dev/disk2)
   --force|-f     Force flash without security prompt (for automation)
   --userdata|-u  Copy this cloud-init config file to /boot/user-data
   --metadata|-m  Copy this cloud-init config file to /boot/meta-data
```

If no image is specified, the script will try to configure an existing
image. This is useful to try several configuration without the need to
rewrite the image every time.

## Configuration

The strength of the flash tool is that it can insert some configuration files that gives you the best first boot experience to customize the hostname, WiFi and even user logins and SSH keys automatically.

### cloud-init

With HypriotOS v1.7.0 and higher the options `--userdata` and `--metadata` can be used to copy both cloud-init config files into the FAT partition.

This is an example how to create our default user with a password.

```yaml
#cloud-config
# vim: syntax=yaml
#
hostname: black-pearl
manage_etc_hosts: true

users:
  - name: pirate
    gecos: "Hypriot Pirate"
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    groups: users,docker,video
    plain_text_passwd: hypriot
    lock_passwd: false
    ssh_pwauth: true
    chpasswd: { expire: false }

package_upgrade: false
```

Please have a look at the [`sample`](sample/) folder, our guest blogpost [Bootstrapping a Cloud with Cloud-Init and HypriotOS](https://blog.hypriot.com/post/cloud-init-cloud-on-hypriot-x64/) or at the [cloud-init documentation](http://cloudinit.readthedocs.io/en/0.7.9/)
how to do more things like using SSH keys, running additional commands etc.

### config.txt

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

### device-init.yaml

For HypriotOS older than v1.7.0 the option `--config` can be used to copy a
`device-init.yaml` into the SD image before it is unplugged. This YAML file can
be read by newer HyperiotOS SD images.

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

## Use cases

### Flash a compressed SD image from the internet

```bash
flash https://github.com/hypriot/image-builder-rpi/releases/download/v1.7.1/hypriotos-rpi-v1.7.1.img.zip
```

### Flash and change the hostname

This works only for SD card images that already have `occi` installed.

```bash
flash --hostname mypi hypriot.img
```

Then unplug the SD card from your computer, plug it into your Pi and boot your
Pi. After a while the Pi can be found via Bonjour/avahi and you can log in with

```bash
ssh pi@mypi.local
```

### Onboard WiFi

The options `--userdata` and `--bootconf` must be used to disable UART and enable onboard WiFi for Raspberry Pi 3 and Pi 0. For external WiFi sticks you do not need to specify the `-bootconf` option.

```
flash --userdata sample/wlan-user-data.yaml --bootconf sample/no-uart-config.txt hypriotos-rpi-v1.7.1.img
```

### Automating flash

For non-interactive usage, you can predefine the user input in the flash command with the `-d` and `-f` options:

```
flash -d /dev/mmcblk0 -f hypriotos-rpi-v1.7.1.img
```

## Development

Pull requests and other feedback is always welcome. The `flash` tool should fit
our all needs and environments.

To develop the flash scripts you need either a Linux or macOS machine to test locally. On a Mac you can use Docker to run the Linux tests in a container and if you dare you can run the macOS tests directly. On a Linux machine you can not test the macOS variant directly. But in every case you can send a pull request and push code to GitHub and the CI pipeline with CircleCI (Linux) and TravisCI (macOS) will test your code for both platforms.

### Local development

The flash script are checked with the [`shellcheck`](https://www.shellcheck.net) static analysis tool.

The integration tests can be run locally on macOS or Linux. We use BATS which is installed with NPM package. So you would need Node.js to setup a local development environment. As the flash script runs `dd` and some commands with `sudo` it is recommended to use the isolated test environment with Docker or run this local tests in a macOS / Linux VM.

```
npm install
npm test
```

### Isolated tests with Docker

If you do not want to install all these development tools (shellcheck, bats, node) and don't trust the flash script enough, you can use Docker instead and run the shellcheck and integration tests in a much safer test environment.

All you need is Docker and `make` installed to run the following tests.

#### Shellcheck

The flash script are checked with the shellcheck static analysis tool.

```
make shellcheck
```

#### Integration tests

The flash script also have BATS integration tests. You don't have to install everything on your development machine. It should be enough to test the Linux variant in a Docker container and then run the macOS tests with TravisCI.

```
make test
```

### Test Linux from Mac

For manual tests of the Linux version on a Mac there is a Vagrant environment. It can be used
to investigate Linux problems when you don't have a baremetal Linux machine. With some help I found a way to spin up a
VirtualBox Vagrant box with Ubuntu that maps the internal Apple SD card reader
into the VM. Thanks to [Flexshot](https://github.com/Flexshot) for the helper
functions I found in [NextThingCo/CHIP-SDK#15](https://github.com/NextThingCo/CHIP-SDK/pull/15).

Check the vendor ID and product ID in "About this Mac" -> System Report ... ->
Card Reader. I found the vendor ID 0x05ac and product ID 0x8406 can be found in
the `Vagrantfile`.

```bash
vagrant up --provider virtualbox
vagrant ssh
cd /vagrant
./flash hypriotos-rpi-v1.7.1.img.zip
```
