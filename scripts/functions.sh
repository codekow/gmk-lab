#!/bin/bash

lab_wol(){
  # MACS=()

  for nic in ${MACS[*]}
  do
    wol $nic
  done
}

create_vm(){
  VM_NAME=${1:-00}
  VM_MAC=${2:-00}
  VM_FILE=files/etc/libvirt/qemu/vm-00.xml

  sed '
      s/vm-00/'"${VM_NAME}"/g'
      s/52:54:00:4e:e0:00/52:54:00:4e:e0:'"${VM_MAC}"/g'
      ' "${VM_FILE}"

}

download_fcos(){
  STREAM=stable
  VERSION=40.20240416.3.1

  BASEURL=https://builds.coreos.fedoraproject.org/prod/streams/${STREAM}/builds/${VERSION}/x86_64

  curl -LO ${BASEURL}/fedora-coreos-${VERSION}-live-kernel-x86_64
  curl -LO ${BASEURL}/fedora-coreos-${VERSION}-live-initramfs.x86_64.img
  curl -LO ${BASEURL}/fedora-coreos-${VERSION}-live-rootfs.x86_64.img
}
