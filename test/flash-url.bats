load test_helper

setup() {
  stub_diskutil
}

teardown() {
  umount_sd_boot
  rm -f $img
  unstub_diskutil
}

@test "flash with url to img.zip works" {
  run ./$OS/flash -f -d $img https://github.com/hypriot/image-builder-rpi/releases/download/v1.7.1/hypriotos-rpi-v1.7.1.img.zip
  assert_success
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/user-data
  assert_success
  assert_output_contains "hostname: black-pearl"
  [[ -e "/tmp/boot/meta-data" ]]
}

@test "flash with url to img.xz works" {
  skip "Download is really slow and the use-case very rare"
  run ./$OS/flash -f -d $img https://ubuntu-mate.org/raspberry-pi/ubuntu-mate-16.04.2-desktop-armhf-raspberry-pi.img.xz
  assert_success
  assert_output_contains Finished.
}
