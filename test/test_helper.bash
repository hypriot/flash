if [ -d ../../node_modules/bats-mock ]; then
  inc=../../node_modules
else
  inc=../node_modules
fi
load $inc/bats-mock/stub
load $inc/bats-assert/all

mount_sd_boot() {
  local dev="$1"
  boot=/tmp/mnt.$$
  mkdir -p "${boot}"
  sudo mount -t vfat "${dev}" "${boot}"
}

mount_sd_boot() {
  local dev="$1"
  mnt="$2"
  mkdir -p "${mnt}"
  sudo mount -t vfat "${dev}" "${mnt}"
}

umount_sd_boot() {
  mnt="$1"
  sudo umount "${mnt}"
}
