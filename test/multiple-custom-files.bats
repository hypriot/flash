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

@test "copying multiple files" {
  run ./flash -f -d $img --file test/resources/note1.txt --file test/resources/note2.txt cloud-init.img
  assert_success
  assert_output_contains Finished.

  mount_sd_boot $img /tmp/boot
  run cat /tmp/boot/note1.txt
  assert_output_contains "lorem ipsum"

  run cat /tmp/boot/note2.txt
  assert_output_contains "hello world"
}
