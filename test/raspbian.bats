load test_helper

setup() {
  stub_diskutil
}

teardown() {
  umount_sd_boot
  rm -f $img
  unstub_diskutil
}

@test "flash with url to Raspbian LITE zip works" {
  skip "Download is really slow"
  run ./$OS/flash -f -d $img https://downloads.raspberrypi.org/raspbian_lite_latest
  assert_success
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/cmdline.txt
  assert_success
  assert_output_contains "console=serial0,115200"

  run cat /tmp/boot/config.txt
  assert_success
  assert_output_contains "dtparam=audio=on"

  [[ ! -f "/tmp/boot/device-init.yaml" ]]
  [[ ! -f "/tmp/boot/user-data" ]]
  [[ ! -f "/tmp/boot/meta-data" ]]
}
