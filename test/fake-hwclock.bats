load test_helper
export OS=$(uname -s)

setup() {
  if [ ! -f fake-hwclock.img ]; then
    # download SD card image with cloud-init
    curl -L -o download.img.zip https://github.com/hypriot/image-builder-rpi/releases/download/1.12.0-rc2/hypriotos-rpi-1.12.0-rc2.img.zip
    unzip download.img.zip
    # cut only 70 MByte to flash faster
    dd if=hypriotos-rpi-1.12.0-rc2.img of=fake-hwclock.img bs=1048576 count=70
  fi
  stub_diskutil
}

teardown() {
  umount_sd_boot /tmp/boot
  rm -f $img
  unstub_diskutil
}

@test "fake-hwclock: flash updates fake-hwclock.data" {
  expected=$(TZ=UTC date '+%Y-%m-%d %H:%M')

  run ./flash -f -d $img fake-hwclock.img
  assert_success

  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/fake-hwclock.data
  assert_output_contains "$expected"

  assert [ -e "/tmp/boot/fake-hwclock.data" ]
}
