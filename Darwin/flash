#!/bin/bash
# Flash Raspberry Pi SD card images on your Mac
# Stefan Scherer - scherer_stefan@icloud.com
# MIT License

usage()
{
  cat << EOF
usage: $0 [options] name-of-rpi.img

Flash a local or remote Raspberry Pi SD card image.

OPTIONS:
  --help|-h       Show this message
  --bootconf|-C   Copy this config file to /boot/config.txt
  --config|-c     Copy this config file to /boot/device-init.yaml (or occidentalis.txt)
  --hostname|-n   Set hostname for this SD image
  --ssid|-s       Set WiFi SSID for this SD image
  --password|-p   Set WiFI password for this SD image
  --clusterlab|-l Start Cluster-Lab on boot: true or false
  --device|-d     Choose device to flash to (e.g. 'disk2' for /dev/disk2)
  --userdata|-u   Copy this cloud-init file to /boot/user-data
  --metadata|-m   Copy this cloud-init file to /boot/meta-data

For HypriotOS devices:

The config file device-init.yaml should look like

hostname: black-pearl
wifi:
  interfaces:
    wlan0:
      ssid: "MyNetwork"
      password: "secret_password"

For Raspberry Pi until Hector release:

The config file occidentalis.txt should look like

# hostname for your Hypriot Raspberry Pi:
hostname=hypriot-pi

# basic wireless networking options:
wifi_ssid=SSID
wifi_password=12345

The boot config file config.txt has name/value pairs such as:

max_usb_current=1

EOF
  exit 1
}

# translate long options to short
for arg
do
  delim=""
  case "${arg}" in
    --help) args="${args}-h ";;
    --verbose) args="${args}-v ";;
    --config) args="${args}-c ";;
    --hostname) args="${args}-n ";;
    --ssid) args="${args}-s ";;
    --password) args="${args}-p ";;
    --bootconf) args="${args}-C ";;
    --clusterlab) args="${args}-l ";;
    --device) args="${args}-d ";;
    --userdata) args="${args}-u ";;
    --metadata) args="${args}-m ";;
    # pass through anything else
    *) [[ "${arg:0:1}" == "-" ]] || delim="\""
      args="${args}${delim}${arg}${delim} ";;
  esac
done
# reset the translated args
eval set -- "$args"
# now we can process with getopt
while getopts ":hc:n:s:p:C:l:d:u:m:" opt; do
  case $opt in
    h)  usage ;;
    c)  CONFIG_FILE=$OPTARG ;;
    C)  BOOT_CONF=$OPTARG ;;
    n)  SD_HOSTNAME=$OPTARG ;;
    s)  WIFI_SSID=$OPTARG ;;
    p)  WIFI_PASSWORD=$OPTARG ;;
    l)  CLUSTERLAB=$OPTARG ;;
    d)  DEVICE=$OPTARG ;;
    u)  USER_DATA=$OPTARG ;;
    m)  META_DATA=$OPTARG ;;
    \?) usage ;;
    :)
      echo "option -$OPTARG requires an argument"
      usage
    ;;
  esac
done
shift $((OPTIND -1))

beginswith() { case $2 in $1*) true;; *) false;; esac; }
endswith() { case $2 in *$1) true;; *) false;; esac; }

image=$1

if [ "$1" == "--help" ]; then
  usage
fi

filename=$(basename "${image}")
extension="${filename##*.}"
filename="${filename%.*}"

if [ ! -z "${USER_DATA}" ]; then
  if [ ! -f "${USER_DATA}" ]; then
    echo "Cloud-init file ${USER_DATA} not found!"
    exit 10
  fi
fi

if [ ! -z "${META_DATA}" ]; then
  if [ ! -f "${META_DATA}" ]; then
    echo "Cloud-init file ${META_DATA} not found!"
    exit 10
  fi
fi

if [ ! -z "${BOOT_CONF}" ]; then
  if [ ! -f "${BOOT_CONF}" ]; then
    echo "File ${BOOT_CONF} not found!"
    exit 10
  fi
fi

if [ ! -z "${CONFIG_FILE}" ]; then
  if [ ! -f "${CONFIG_FILE}" ]; then
    echo "File ${CONFIG_FILE} not found!"
    exit 10
  fi
fi

if [ -f "/tmp/${filename}" ]; then
  image=/tmp/${filename}
  echo "Using cached image ${image}"
elif [ -f "/tmp/${filename}.img" ]; then
  image=/tmp/${filename}.img
  echo "Using cached image ${image}"
else
  if beginswith http:// "${image}" || beginswith https:// "${image}"; then
    which curl >/dev/null || (echo "Error: curl not found. Aborting" && exit 1)
    echo "Downloading ${image} ..."
    curl -L -o "/tmp/image.img.${extension}" "${image}"
    image=/tmp/image.img.${extension}
  fi

  if beginswith s3:// "${image}"; then
    which aws >/dev/null || (echo "Error: aws not found. Aborting" && exit 1)
    echo "Downloading ${image} ..."
    aws s3 cp "${image}" "/tmp/image.img.${extension}"
    image=/tmp/image.img.${extension}
  fi

  if [ ! -f "${image}" ]; then
    echo "File ${image} not found!"
    exit 10
  fi

  if [[ "$(file "${image}")" == *"Zip archive"* ]]; then
    echo "Uncompressing ${image} ..."
    unzip -o "${image}" -d /tmp
    image=$(unzip -l "${image}" | grep --color=never -v Archive: | grep --color=never img | awk 'NF>1{print $NF}')
    image="/tmp/${image}"
    echo "Use ${image}"
  fi
  if [[ "$(file "${image}")" == *"gzip compressed data"* ]]; then
    echo "Uncompressing ${image} ..."
    gzip -d "${image}" -c >/tmp/image.img
    image=/tmp/image.img
    echo "Use ${image}"
  fi
  if [[ "$(file "${image}")" == *"xz compressed data"* ]]; then
    echo "Uncompressing ${image} ..."
    xz -d "${image}" -c >/tmp/image.img
    image=/tmp/image.img
    echo "Use ${image}"
  fi
fi

if [[ "${OSTYPE}" != "darwin"* ]]; then
  echo "This version does only support Mac."
  echo "Please download correct version from https://github.com/hypriot/flash"
  exit 11
fi

while true; do
  # default to device passed by user
  disk="$DEVICE"
  if [ "${disk}" == "" ]; then
    # try to find the correct disk of the inserted SD card
    disk=$(diskutil list | grep --color=never FDisk_partition_scheme | awk 'NF>1{print $NF}')
  fi
  if [ "${disk}" == "" ]; then
    echo "No SD card found. Please insert SD card, I'll wait for it..."
    while [ "${disk}" == "" ]; do
      sleep 1
      disk=$(diskutil list | grep --color=never FDisk_partition_scheme | awk 'NF>1{print $NF}')
    done
  fi

  df -h
  while true; do
    echo ""
    read -rp "Is /dev/${disk} correct? " yn
    case $yn in
      [Yy]* ) break;;
      [Nn]* ) exit;;
      * ) echo "Please answer yes or no.";;
    esac
  done

  echo "Unmounting ${disk} ..."
  diskutil unmountDisk "/dev/${disk}s1"
  diskutil unmountDisk "/dev/${disk}"
  readonlymedia=$(diskutil info "/dev/${disk}" | grep "Read-Only Media" | awk 'NF>1{print $NF}')
  if [ "$readonlymedia" == "No" ]; then
    break
  else
    afplay /System/Library/Sounds/Basso.aiff
    echo "👎  The SD card is write protected. Please eject, remove protection and insert again."
  fi
done

echo "Flashing ${image} to ${disk} ..."
if [[ -x $(which pv) ]]; then
  # this sudo here is used for a login without pv's progress bar
  # hiding the password prompt
  size=$(sudo /usr/bin/stat -f %z ${image})
  pv -s "${size}" < ${image} | sudo /bin/dd bs=1m "of=/dev/r${disk}"
else
  echo "No 'pv' command found, so no progress available."
  echo "Press CTRL+T if you want to see the current info of dd command."
  sudo /bin/dd bs=1m if=${image} "of=/dev/r${disk}"
fi

boot=$(df | grep --color=never "/dev/${disk}s1" | /usr/bin/sed 's,.*/Volumes,/Volumes,')
if [ "${boot}" == "" ]; then
  COUNTER=0
  while [ $COUNTER -lt 5 ]; do
    sleep 1
    boot=$(df | grep --color=never "/dev/${disk}s1" | /usr/bin/sed 's,.*/Volumes,/Volumes,')
    if [ "${boot}" != "" ]; then
      break
    fi
    let COUNTER=COUNTER+1
  done
fi

# customize for first boot
if [ "${boot}" ]; then
  if [ -f "${CONFIG_FILE}" ]; then
    if [[ "${CONFIG_FILE}" == *"occi"* ]]; then
      echo "Copying ${CONFIG_FILE} to ${boot}/occidentalis.txt ..."
      cp "${CONFIG_FILE}"  "${boot}/occidentalis.txt"
    else
      echo "Copying ${CONFIG_FILE} to ${boot}/device-init.yaml ..."
      cp "${CONFIG_FILE}"  "${boot}/device-init.yaml"
    fi
  fi

  if [[ -f "${BOOT_CONF}" ]]; then
    echo "Copying ${BOOT_CONF} to ${boot}/config.txt ..."
    sudo cp "${BOOT_CONF}" "${boot}/config.txt"
  fi

  if [ -f "${USER_DATA}" ]; then
    echo "Copying cloud-init ${USER_DATA} to ${boot}/user-data ..."
    sudo cp "${USER_DATA}" "${boot}/user-data"
  fi

  if [ -f "${META_DATA}" ]; then
    echo "Copying cloud-init ${META_DATA} to ${boot}/meta-data ..."
    sudo cp "${META_DATA}" "${boot}/meta-data"
  fi

  if [ -f "${boot}/device-init.yaml" ]; then
    if [ ! -z "${SD_HOSTNAME}" ]; then
      echo "Set hostname=${SD_HOSTNAME}"
      /usr/bin/sed -i "" -e "s/.*hostname:.*\$/hostname: ${SD_HOSTNAME}/" "${boot}/device-init.yaml"
    fi
    if [ ! -z "${WIFI_SSID}" ]; then
      echo "Set wlan0/ssid=${WIFI_SSID}"
      /usr/bin/sed -i "" -e "s/.*wlan0:.*\$/    wlan0:/" "${boot}/device-init.yaml"
      /usr/bin/sed -i "" -e "s/.*ssid:.*\$/      ssid: \"${WIFI_SSID}\"/" "${boot}/device-init.yaml"
    fi
    if [ ! -z "${WIFI_PASSWORD}" ]; then
      echo "Set wlan0/password=${WIFI_PASSWORD}"
      /usr/bin/sed -i "" -e "s/.*wlan0:.*\$/    wlan0:/" "${boot}/device-init.yaml"
      /usr/bin/sed -i "" -e "s/.*password:.*\$/      password: \"${WIFI_PASSWORD}\"/" "${boot}/device-init.yaml"
    fi
    if [ ! -z "${CLUSTERLAB}" ]; then
      echo "Set Cluster-Lab/run_on_boot={CLUSTERLAB}"
      /usr/bin/sed -i "" -e "s/.*run_on_boot.*\$/    run_on_boot: \"${CLUSTERLAB}\"/" "${boot}/device-init.yaml"
    fi
  fi

  # cloud-init
  if [ -f "${boot}/user-data" ]; then
    if [ ! -z "${SD_HOSTNAME}" ]; then
      echo "Set hostname=${SD_HOSTNAME}"
      /usr/bin/sed -i "" -e "s/.*hostname:.*\$/hostname: ${SD_HOSTNAME}/" "${boot}/user-data"
    fi

    if [ ! -f "${boot}/meta-data" ]; then
      echo "Creating empty meta-data"
      touch "${boot}/meta-data"
    fi
  fi

  # legacy: /boot/occidentalis.txt of old Hector release
  if [ -f "${boot}/occidentalis.txt" ]; then
    if [ ! -z "${SD_HOSTNAME}" ]; then
      echo "Set hostname=${SD_HOSTNAME}"
      /usr/bin/sed -i "" -e "s/.*hostname.*=.*\$/hostname=${SD_HOSTNAME}/" "${boot}/occidentalis.txt"
    fi
    if [ ! -z "${WIFI_SSID}" ]; then
      echo "Set wifi_ssid=${WIFI_SSID}"
      /usr/bin/sed -i "" -e "s/.*wifi_ssid.*=.*\$/wifi_ssid=${WIFI_SSID}/" "${boot}/occidentalis.txt"
    fi
    if [ ! -z "${WIFI_PASSWORD}" ]; then
      echo "Set wifi_password=${WIFI_PASSWORD}"
      /usr/bin/sed -i "" -e "s/.*wifi_password.*=.*\$/wifi_password=${WIFI_PASSWORD}/" "${boot}/occidentalis.txt"
    fi
  fi
fi

echo "Unmounting and ejecting ${disk} ..."
sleep 1
diskutil unmountDisk "/dev/${disk}s1"
diskutil unmountDisk "/dev/${disk}s2"
diskutil eject "/dev/${disk}"
if [ $? -eq 0 ]; then
  afplay /System/Library/Sounds/Bottle.aiff
  echo "🍺  Finished."
else
  afplay /System/Library/Sounds/Basso.aiff
  echo "👎  Something went wrong."
fi
