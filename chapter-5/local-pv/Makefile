
.PHONY: disk
disk:
	mkdir /mnt/disks
	for vol in vol1 vol2 vol3; do \
	   mkdir /ment/disks/$$vol \
	   mount -t tmpfs $$vol /mnt/disks/$$vol \
	done