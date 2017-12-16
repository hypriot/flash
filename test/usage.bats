load test_helper

@test "usage Darwin" {
  run ./Darwin/flash --help
  [ "$status" -eq 1 ]
  assert_output_contains usage:
}

@test "usage Linux" {
  run ./Linux/flash --help
  [ "$status" -eq 1 ]
  assert_output_contains usage:
}
