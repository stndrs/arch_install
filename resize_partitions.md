# Volume information

```
# pvs
# vgs
# lvs
```

1. Boot into Arch ISO
2. Decrypt luks partition
3. Check for filesystem errors
```
e2fsck -f /dev/mapper/<partition>
e2fsck -f /dev/mapper/<other-partition>
```
4. Resize the filesystem to the desired size
```
resize2fs /dev/mapper/<partition> 100G
```
5. Reduce the LVM size to the same as above
```
lvreduce -L 20G /dev/mapper/<partition>
```
6. Extend <other-partition> to new size
```
lvextend -l +100%FREE /dev/mapper/<other-partition>
```
7. Grow the other filesystem to the size of the LVM
```
resize2fs /dev/mapper/<other-partition>
```
8. Reboot

