load test_helper

@test "flash --help shows usage" {
  run ./flash --help
  [ "$status" -eq 1 ]
  assert_output_contains usage:
}

@test "flash without parameters shows usage" {
  run ./flash
  [ "$status" -eq 1 ]
  assert_output_contains usage:
}
