#!/bin/bash
# update bins from the internet
# set -x

init(){
  CURRENT_DIR=${PWD##*/}
  TFTP_DIR=tftpboot

  if [ "${CURRENT_DIR}" = "${TFTP_DIR}"  ]; then
    echo "CURRENT_DIR: ${CURRENT_DIR}"
  else
    echo "Run this script from the ${TFTP_DIR} folder"
    exit 0
  fi
}

download() {
if [ ! -z "${2}" ]; then
  [ -e ${2} ] && return
  wget -N "${1}" -O "${2}"
else
  wget -N "${1}"
fi
}

download_to_name(){
  URL=${1}
  OUTPUT=${2}

  wget -N "${URL}" -O "${OUTPUT}"
}

download_list(){
  URL=${1}
  LIST=${2}
  OUTPUT=${3}

  [ ! -d "${OUTPUT}" ] && mkdir "${OUTPUT}"

  pushd "${OUTPUT}"
  for bin in ${LIST}
  do
    download "${URL}/${bin}"
  done
  popd
}

download_ipxe(){
  FOLDER='ipxe'
  [ ! -d "${FOLDER}" ] && mkdir -p "${FOLDER}"

  URL="http://boot.ipxe.org"
  LIST="ipxe.efi ipxe.iso ipxe.pxe ipxe.lkrn ipxe.usb undionly.kpxe ipxe.png"
  OUTPUT=ipxe

  download_list "${URL}" "${LIST}" "${OUTPUT}"
}

download_netboot(){
  FOLDER='local/netboot'
  [ ! -d "${FOLDER}" ] && mkdir -p "${FOLDER}"

  URL="https://boot.netboot.xyz/ipxe"
  LIST="$(echo netboot.xyz.{iso,img,dsk,pdsk,lkrn,kpxe,efi} netboot.xyz-{snp,snponly}.efi) netboot.xyz-efi.iso netboot.xyz-undionly.kpxe"
  OUTPUT=local/netboot

  download_list "${URL}" "${LIST}" "${OUTPUT}"
}

download_wimboot(){
  FOLDER='ipxe'
  [ ! -d "${FOLDER}" ] && mkdir -p "${FOLDER}"

  URL="https://github.com/ipxe/wimboot/blob/master/wimboot?raw=true"
  OUTPUT=ipxe/wimboot

  download "${URL}" "${OUTPUT}"
}

download_freedos(){
  FOLDER='local/freedos'
  [ ! -d "${FOLDER}" ] && mkdir -p "${FOLDER}"

  pushd "${FOLDER}"
    download "https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.3/official/FD13-FloppyEdition.zip"
    unzip -u FD13-FloppyEdition.zip
    rm FD13-FloppyEdition.zip
    mv 144m/x86BOOT.img .
    rm -rf 720k 120m 144m

    download "https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.3/official/FD13-LiteUSB.zip"
    unzip -u FD13-LiteUSB.zip
    rm FD13-LiteUSB.zip
    rm *.vmdk
  popd
}

download_misc(){
  FOLDER='local/misc'
  [ ! -d "${FOLDER}" ] && mkdir -p "${FOLDER}"

  pushd "${FOLDER}"
    download "https://www.memtest.org/download/v6.00/mt86plus_6.00_64.iso.zip"
    unzip -u mt86plus_6.00_64.iso.zip
    rm mt86plus_6.00_64.iso.zip
  popd
}

download_coreos(){
  FOLDER='local/coreos'
  [ ! -d "${FOLDER}" ] && mkdir -p "${FOLDER}"

  pushd "${FOLDER}"
    version='36.20221030.3.0'
    curl -L --remote-name-all https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/${version}/x86_64/fedora-coreos-${version}-{live-initramfs.x86_64.img,live-kernel-x86_64,live-rootfs.x86_64.img,live.x86_64.iso}
  popd
}

download_rhcos(){
  FOLDER='local/rhcos'
  [ ! -d "${FOLDER}" ] && mkdir -p "${FOLDER}"

  URL="https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest"
  # URL="https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.9/latest"

  LIST="sha256sum.txt rhcos-installer-kernel-x86_64 rhcos-installer-initramfs.x86_64.img rhcos-installer-rootfs.x86_64.img"
  OUTPUT="${FOLDER}"

  download_list "${URL}" "${LIST}" "${OUTPUT}"

  pushd "${FOLDER}"
      sha256sum --ignore-missing -c sha256sum.txt
  popd
}

download_fedora(){
  VERSION=${1:-39}
  FOLDER="local/fedora/${VERSION}"
  [ ! -d "${FOLDER}" ] && mkdir -p "${FOLDER}"

  BASE_URL="https://download.fedoraproject.org/pub/fedora/linux/releases/${VERSION}"
  URL="${BASE_URL}/Server/x86_64/os/images/pxeboot"

  LIST="vmlinuz initrd.img"
  OUTPUT="${FOLDER}"

  download_list "${URL}" "${LIST}" "${OUTPUT}"

  URL="${BASE_URL}/Server/x86_64/os/images"
  LIST="efiboot.img eltorito.img install.img"

  download_list "${URL}" "${LIST}" "${OUTPUT}/images"

}

download_fedora_live(){
  FOLDER='local/fedora/37'
  [ ! -d "${FOLDER}" ] && mkdir -p "${FOLDER}"

  URL="https://github.com/netbootxyz/fedora-assets/releases/download/1.7-b9ac9551/"

  LIST="vmlinuz initrd squashfs.img"
  OUTPUT="${FOLDER}"

  download_list "${URL}" "${LIST}" "${OUTPUT}"
}

download_ubutu_live(){
  FOLDER='local/ubuntu/22.04'
  [ ! -d "${FOLDER}" ] && mkdir -p "${FOLDER}"

  URL="https://github.com/netbootxyz/ubuntu-squash/releases/download/22.04.1-54de5f62/"

  LIST="vmlinuz initrd filesystem.squashfs"
  OUTPUT="${FOLDER}"

  download_list "${URL}" "${LIST}" "${OUTPUT}"
}


main() {
  init
  download_ipxe
  download_netboot
  download_wimboot
  download_coreos
  download_fedora_live
  download_misc
}

# main
