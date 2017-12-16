load test_helper

@test "flash shows usage on Darwin" {
  run ./Darwin/flash --help
  [ "$status" -eq 1 ]
  assert_output_contains usage:
}

@test "flash shows usage on Linux" {
  run ./Linux/flash --help
  [ "$status" -eq 1 ]
  assert_output_contains usage:
}

@test "flash aborts without parameters" {
  run ./Linux/flash
  [ "$status" -eq 10 ]
  assert_output_contains "not found!"
}
