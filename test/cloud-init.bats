load test_helper

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

@test "cloud-init: flash works" {
  run ./flash -f -d $img cloud-init.img
  assert_success

  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/user-data
  assert_output_contains "hostname: black-pearl"
  assert_output_contains "name: pirate"
  assert_output_contains "plain_text_passwd: hypriot"

  [[ -e "/tmp/boot/meta-data" ]]
  [[ ! -s "/tmp/boot/meta-data" ]]
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

  [[ -e "/tmp/boot/meta-data" ]]
  [[ ! -s "/tmp/boot/meta-data" ]]
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

  [[ -e "/tmp/boot/meta-data" ]]
  [[ ! -s "/tmp/boot/meta-data" ]]
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

  [[ -e "/tmp/boot/meta-data" ]]
  [[ ! -s "/tmp/boot/meta-data" ]]
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

  [[ -e "/tmp/boot/meta-data" ]]
  [[ ! -s "/tmp/boot/meta-data" ]]

  run cat /tmp/boot/config.txt
  assert_output_contains "enable_uart=0"
}
