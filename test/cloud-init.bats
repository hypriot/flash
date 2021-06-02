load test_helper
export OS=$(uname -s)

setup() {
  if [ ! -f cloud-init.img ]; then
    # download SD card image with cloud-init
    curl -L -o download.img.zip https://github.com/hypriot/image-builder-rpi/releases/download/v1.7.1/hypriotos-rpi-v1.7.1.img.zip
    unzip download.img.zip
    # cut only 70 MByte to flash faster
    dd if=hypriotos-rpi-v1.7.1.img of=cloud-init.img bs=1048576 count=70
  fi
  stub_diskutil
}

teardown() {
  umount_sd_boot /tmp/boot
  rm -f $img
  unstub_diskutil
}

@test "cloud-init: flash aborts if YAML is missing #cloud-config comment" {
  run ./flash -f -d $img -u test/resources/missing-comment.yml cloud-init.img
  assert_failure

  assert_output_contains "is not a valid YAML file"
}

@test "cloud-init: flash aborts if YAML does not start with #cloud-config comment" {
  run ./flash -f -d $img -u test/resources/comment-not-in-first-line.yml cloud-init.img
  assert_failure

  assert_output_contains "is not a valid YAML file"
}

@test "cloud-init: flash aborts if YAML is not valid" {
  if [ "${OS}" == "Darwin" ]; then
    run ./flash -f -d $img -u test/resources/bad.yml cloud-init.img
    assert_failure

    assert_output_contains "is not a valid YAML file"
  fi
}

@test "cloud-init: flash works" {
  run ./flash -f -d $img cloud-init.img
  assert_success

  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/user-data
  assert_output_contains "hostname: black-pearl"
  assert_output_contains "name: pirate"
  assert_output_contains "plain_text_passwd: hypriot"

  assert [ ! -e "/tmp/boot/user-data-e" ]

  assert [ -e "/tmp/boot/meta-data" ]
  assert [ ! -s "/tmp/boot/meta-data" ]
}

@test "cloud-init: flash --hostname sets hostname" {
  run ./flash -f -d $img --hostname myhost cloud-init.img
  assert_success
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/user-data
  assert_output_contains "hostname: myhost"
  assert_output_contains "name: pirate"
  assert_output_contains "plain_text_passwd: hypriot"

  assert [ ! -e /tmp/boot/user-data-e ]

  assert [ -e /tmp/boot/meta-data ]
  assert [ ! -s /tmp/boot/meta-data ]
}

@test "cloud-init: flash --ssid does NOT set ssid as it's COMMENTED in default image" {
  run ./flash -f -d $img --ssid NEWSSID cloud-init.img
  assert_success
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/user-data
  refute_output_contains 'ssid="NEWSSID"'
}

@test "cloud-init: flash --password does NOT set psk as it's COMMENTED in default image" {
  run ./flash -f -d $img --password NEWPSK cloud-init.img
  assert_success
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/user-data
  refute_output_contains 'psk="NEWPSK"'
}

@test "cloud-init: flash --ssid still sets ssid when user-data also specified" {
  run ./flash -f -d $img -u test/resources/wifi-user-data.yml --ssid NEWSSID cloud-init.img
  assert_success
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/user-data
  assert_output_contains 'ssid="NEWSSID"'
}

@test "cloud-init: flash --password still sets psk when user-data also specified" {
  run ./flash -f -d $img -u test/resources/wifi-user-data.yml --password NEWPSK cloud-init.img
  assert_success
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/user-data
  assert_output_contains 'psk="NEWPSK"'
}

@test "cloud-init: flash --ssid does NOT set ssid if COMMENTED when user-data also specified" {
  run ./flash -f -d $img -u test/resources/wifi-commented-user-data.yml --ssid NEWSSID cloud-init.img
  assert_success
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/user-data
  refute_output_contains 'ssid="NEWSSID"'
}

@test "cloud-init: flash --password does NOT set psk if COMMENTED when user-data also specified" {
  run ./flash -f -d $img -u test/resources/wifi-commented-user-data.yml --password NEWPSK cloud-init.img
  assert_success
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/user-data
  refute_output_contains 'psk="NEWPSK"'
}

@test "cloud-init: flash --config does not replace user-data" {
  run ./flash -f -d $img --config test/resources/good.yml cloud-init.img
  assert_success
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/user-data
  assert_output_contains "hostname: black-pearl"
  assert_output_contains "name: pirate"
  assert_output_contains "plain_text_passwd: hypriot"

  assert [ -e "/tmp/boot/meta-data" ]
  assert [ ! -s "/tmp/boot/meta-data" ]
}

@test "cloud-init: flash --userdata replaces user-data" {
  run ./flash -f -d $img --userdata test/resources/good.yml cloud-init.img
  assert_success
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/user-data
  assert_output_contains "hostname: good"
  assert_output_contains "name: other"
  assert_output_contains "ssh-authorized-keys:"

  assert [ -e "/tmp/boot/meta-data" ]
  assert [ ! -s "/tmp/boot/meta-data" ]
}

@test "cloud-init: flash --metadata replaces meta-data" {
  run ./flash -f -d $img --userdata test/resources/good.yml --metadata test/resources/meta.yml cloud-init.img
  assert_success
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/user-data
  assert_output_contains "hostname: good"
  assert_output_contains "name: other"
  assert_output_contains "ssh-authorized-keys:"

  run cat /tmp/boot/meta-data
  assert_output_contains "instance-id: iid-local01"
}

@test "cloud-init: flash --bootconf replaces config.txt" {
  run ./flash -f -d $img --bootconf test/resources/no-uart.txt cloud-init.img
  assert_success
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/user-data
  assert_output_contains "hostname: black-pearl"
  assert_output_contains "name: pirate"
  assert_output_contains "plain_text_passwd: hypriot"

  assert [ -e "/tmp/boot/meta-data" ]
  assert [ ! -s "/tmp/boot/meta-data" ]

  run cat /tmp/boot/config.txt
  assert_output_contains "enable_uart=0"
}

@test "cloud-init: flash --userdata can be downloaded" {
  run ./flash -f -d $img --userdata https://raw.githubusercontent.com/hypriot/flash/master/test/resources/good.yml cloud-init.img
  assert_success
  assert_output_contains Downloading
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/user-data
  assert_output_contains "hostname: good"
  assert_output_contains "name: other"
  assert_output_contains "ssh-authorized-keys:"

  assert [ -e "/tmp/boot/meta-data" ]
  assert [ ! -s "/tmp/boot/meta-data" ]
}

@test "cloud-init: flash --metadata can be downloaded" {
  run ./flash -f -d $img --userdata test/resources/good.yml --metadata https://raw.githubusercontent.com/hypriot/flash/master/test/resources/meta.yml cloud-init.img
  assert_success
  assert_output_contains Downloading
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/user-data
  assert_output_contains "hostname: good"
  assert_output_contains "name: other"
  assert_output_contains "ssh-authorized-keys:"

  run cat /tmp/boot/meta-data
  assert_output_contains "instance-id: iid-local01"
}

@test "cloud-init: flash --userdata aborts on 'not found' (404)" {
  run ./flash -f -d $img --userdata https://raw.githubusercontent.com/hypriot/flash/master/test/resources/foo.bar cloud-init.img
  assert_failure

  assert_output_contains "The requested URL returned error: 404"
}
