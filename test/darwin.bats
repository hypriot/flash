load test_helper

@test "flash --help shows usage" {
  run ./$OS/flash --help
  [ "$status" -eq 1 ]
  assert_output_contains usage:
}

@test "flash without parameters shows usage" {
  run ./$OS/flash
  [ "$status" -eq 1 ]
  assert_output_contains usage:
}

@test "test sudo command" {
  run sudo ls
  [ "$status" -eq 0 ]
  assert_output_contains README.md
}
