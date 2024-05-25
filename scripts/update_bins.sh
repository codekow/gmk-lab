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

download_list(){
  URL=${1}
  LIST=${2}
  OUTPUT=${3}

  [ ! -d "${OUTPUT}" ] && mkdir -p "${OUTPUT}"

  for bin in ${LIST}
  do
    download "${URL}/${bin}" "${OUTPUT}/${bin}"
  done
}

download_ipxe(){
  FOLDER='ipxe'
  [ ! -d "${FOLDER}" ] && mkdir -p "${FOLDER}"

  URL="http://boot.ipxe.org"
  LIST="ipxe.efi ipxe.iso ipxe.pxe ipxe.lkrn ipxe.usb undionly.kpxe ipxe.png"
  OUTPUT=ipxe

  download_list "${URL}" "${LIST}" "${OUTPUT}"
}

download_wimboot(){
  FOLDER='ipxe'
  [ ! -d "${FOLDER}" ] && mkdir -p "${FOLDER}"

  URL="https://github.com/ipxe/wimboot/blob/master/wimboot?raw=true"
  OUTPUT=ipxe/wimboot

  download "${URL}" "${OUTPUT}"
}

download_memtest(){
  FOLDER='local/memtest'
  [ ! -d "${FOLDER}" ] && mkdir -p "${FOLDER}"

    cd "${FOLDER}"

    download "https://memtest.org/download/v7.00/mt86plus_7.00.binaries.zip"
    unzip mt86plus_*.zip
    rm mt86plus_*.zip

    cd ../..
}

download_fedora_ks(){
  OS_VER=${1:-40}
  OS_TYPE=${2:-Server}
  FOLDER="local/fedora/${OS_VER}/Server/x86_64/os/images"

  [ ! -d "${FOLDER}" ] && mkdir -p "${FOLDER}/pxeboot"

  URL="https://download.fedoraproject.org/pub/fedora/linux/releases/${OS_VER}/Server/x86_64/os/images"

  LIST="pxeboot/vmlinuz pxeboot/initrd.img install.img"
  OUTPUT="${FOLDER}"

  download_list "${URL}" "${LIST}" "${OUTPUT}"

}

download_fedora_repo(){
  OS_VER=${1:-40}
  OS_TYPE=${2:-Server}
  # URL="https://download.fedoraproject.org/pub/fedora/linux/releases/${OS_VER}/Server/x86_64/os/"
  URL="https://mirror.arizona.edu/fedora/linux/releases/${OS_VER}/${OS_TYPE}/x86_64/os/"
  FOLDER="local/fedora/${OS_VER}/${OS_TYPE}/x86_64/os"

  [ ! -d "${FOLDER}" ] && mkdir -p "${FOLDER}"

  cd "${FOLDER}"
  wget -e robots=off -m -nH -N -r --cut-dirs=8 -np -R "index.html*" "${URL}"
  cd ../../../../../../

  # lftp -e "mirror -R ${OUTPUT} fedora/linux/releases/39/Server/x86_64/os" https://southfront.mm.fcix.net
  # curl -sL "${URL}/.treeinfo" -o "${OUTPUT}"
}

download_fedora_server_iso(){
  OS_VER=${1:-40}

  FOLDER="local/fedora/${OS_VER}/Server/x86_64"
  [ ! -d "${FOLDER}" ] && mkdir -p "${FOLDER}"/{iso,os}
  download "https://download.fedoraproject.org/pub/fedora/linux/releases/${OS_VER}/Server/x86_64/iso/Fedora-Server-dvd-x86_64-40-1.14.iso" "${FOLDER}/iso/Fedora-Server-dvd-x86_64-40-1.14.iso"

  # FOLDER="local/fedora/${OS_VER}/Everything/x86_64/"
  # [ ! -d "${FOLDER}" ] && mkdir -p "${FOLDER}"/{iso,os}
  # download "https://download.fedoraproject.org/pub/fedora/linux/releases/${OS_VER}/Everything/x86_64/iso/Fedora-Everything-netinst-x86_64-40-1.14.iso" "${FOLDER}/iso/Fedora-Everything-netinst-x86_64-40-1.14.iso"

}

main() {
  init
  download_ipxe
  download_wimboot
  download_memtest
  download_fedora_ks
  download_fedora_server_iso
  # download_fedora_repo
}

main
