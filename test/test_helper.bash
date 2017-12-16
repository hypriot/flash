if [ -d ../../node_modules/bats-mock ]; then
  inc=../../node_modules
else
  inc=../node_modules
fi
load $inc/bats-mock/stub
load $inc/bats-assert/all
