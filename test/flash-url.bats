load test_helper

@test "flash from url" {
  run ./Linux/flash -f -d loo https://github.com/hypriot/image-builder-rpi/releases/download/v1.7.1/hypriotos-rpi-v1.7.1.img.zip
  assert_success
  assert_output_contains Finished.
}
