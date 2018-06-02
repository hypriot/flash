load test_helper

expected=$CIRCLE_TAG
if [ -z "$CIRCLE_TAG" ]; then
  expected=dirty
fi

@test "flash --version shows version $expected" {
  run ./flash --version
  [ "$status" -eq 0 ]
  assert_output_contains $expected
}
