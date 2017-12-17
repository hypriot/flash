export OS=$(uname -s)

if [ -d ../../node_modules/bats-mock ]; then
  inc=../../node_modules
else
  inc=../node_modules
fi
load $inc/bats-mock/stub
load $inc/bats-assert/all

if [ "${OS}" == "Darwin" ]; then
  # macOS needs extension .img for temp image
  img=loo.img
else
  # Linux uses a substring of loop device for temp image
  img=loo
fi

stub_diskutil() {
  if [ "${OS}" == "Darwin" ]; then
    # mock for macOS diskutil
    stub diskutil \
    " : true" \
    " : true" \
    " : echo '    Read-Only Media:          No'"
  fi
}

unstub_diskutil() {
  if [ "${OS}" == "Darwin" ]; then
    unstub diskutil
  fi
}

mount_sd_boot() {
  local dev="$1"
  mnt="$2"
  mkdir -p "${mnt}"
  if [ "${OS}" == "Darwin" ]; then
    hdiutil attach -mountpoint "${mnt}" "${dev}"
  else
    sudo mount -t vfat "${dev}" "${mnt}"
  fi
}

umount_sd_boot() {
  mnt="$1"
  if [ "${OS}" == "Darwin" ]; then
    hdiutil detach "${mnt}"
  else
    sudo umount "${mnt}"
  fi
}
