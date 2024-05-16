#!/bin/bash

lab_wol(){
  MACS=(F4:4D:30:6E:95:78 E0:51:D8:12:CF:1B E0:51:D8:12:D2:1A E0:51:D8:12:D7:B5 58:47:CA:75:3C:F3)

  for nic in ${MACS[*]}
  do
    wol $nic
  done
}

download_fcos(){
  STREAM=stable
  VERSION=40.20240416.3.1

  BASEURL=https://builds.coreos.fedoraproject.org/prod/streams/${STREAM}/builds/${VERSION}/x86_64

  curl -LO ${BASEURL}/fedora-coreos-${VERSION}-live-kernel-x86_64
  curl -LO ${BASEURL}/fedora-coreos-${VERSION}-live-initramfs.x86_64.img
  curl -LO ${BASEURL}/fedora-coreos-${VERSION}-live-rootfs.x86_64.img
}
