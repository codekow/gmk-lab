# Notes Dump

NVMe

```
# check for 4kn advanced format ability
sudo nvme id-ns -H /dev/nvme0n1
# change lba format
sudo nvme format --lbaf=1 /dev/nvme0n1 --format
```
