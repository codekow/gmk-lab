# Notes Dump

NVMe

```
# check for 4kn advanced format ability
sudo nvme id-ns -H /dev/nvme0n1
# change lba format
sudo nvme format --lbaf=1 /dev/nvme0n1 --format
```

Bridge Setup

```
bridge_config(){
  NIC=$(ls /sys/class/net/enp?s0)
  nmcli con add ifname br0 type bridge con-name br0
  nmcli con add type bridge-slave ifname "${NIC}" master br0
  nmcli con modify br0 bridge.stp no

  nmcli con down "${NIC}"
  nmcli con up br0
}

bridge_config &
```
