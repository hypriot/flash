load test_helper

setup() {
  if [ ! -f device-init.img ]; then
    # download SD card image with device-init.yaml
    curl -L -o download.img.zip https://github.com/hypriot/image-builder-rpi/releases/download/v1.6.0/hypriotos-rpi-v1.6.0.img.zip
    unzip download.img.zip
    # cut only 70 MByte to flash faster
    dd if=hypriotos-rpi-v1.6.0.img of=device-init.img bs=1048576 count=70
  fi
  stub_diskutil
}

teardown() {
  umount_sd_boot /tmp/boot
  rm -f $img
  unstub_diskutil
}

@test "device-init: flash works" {
  run ./flash -f -d $img device-init.img
  assert_success
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/device-init.yaml
  assert_output_contains "hostname: black-pearl"
  assert_output_contains "#       ssid:"
  assert_output_contains "#       password:"
}

@test "device-init: flash --hostname sets hostname" {
  run ./flash -f -d $img --hostname myhost device-init.img
  assert_success
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/device-init.yaml
  assert_output_contains "hostname: myhost"
  assert_output_contains "#       ssid:"
  assert_output_contains "#       password:"
}

@test "device-init: flash --ssid sets WiFi" {
  run ./flash -f -d $img --ssid myssid --password mypsk device-init.img
  assert_success
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/device-init.yaml
  assert_output_contains "hostname: black-pearl"
  assert_output_contains '      ssid: "myssid"'
  assert_output_contains '      password: "mypsk"'
}

@test "device-init: flash --config replaces device-init.yaml" {
  run ./flash -f -d $img --config test/resources/device.yml device-init.img
  assert_success
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/device-init.yaml
  assert_output_contains "hostname: other"
  assert_output_contains 'ssid: "SSID"'
  assert_output_contains 'password: "PSK"'
}

@test "device-init: flash --bootconf replaces config.txt" {
  run ./flash -f -d $img --bootconf test/resources/no-uart.txt device-init.img
  assert_success
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/device-init.yaml
  assert_output_contains "hostname: black-pearl"
  assert_output_contains "#       ssid:"
  assert_output_contains "#       password:"

  run cat /tmp/boot/config.txt
  assert_output_contains "enable_uart=0"
}
