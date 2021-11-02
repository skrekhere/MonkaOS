IMAGE := MonkaOS.img
MOUNTDIR := img_mount

build: monka image

full: clean limine monka image qemu

monka:
	make -C kernel

image:
	dd if=/dev/zero bs=1M count=0 seek=64 of=$(IMAGE)
	
	parted -s $(IMAGE) mklabel gpt
	
	parted -s $(IMAGE) mkpart ESP fat32 2048s 100%
	parted -s $(IMAGE) set 1 esp on
	
	./limine/limine-install $(IMAGE)
	
	$(eval USED_LOOPBACK:=$(shell sudo losetup -Pf --show $(IMAGE)))
	
	sudo mkfs.fat -F 32 ${USED_LOOPBACK}p1
	
	mkdir -p $(MOUNTDIR)
	sudo mount ${USED_LOOPBACK}p1 $(MOUNTDIR)
	
	sudo mkdir -p $(MOUNTDIR)/EFI/BOOT
	sudo cp -v kernel/MonkaOS.elf limine.cfg limine/limine.sys $(MOUNTDIR)/
	sudo cp -v limine/BOOTX64.EFI $(MOUNTDIR)/EFI/BOOT/
	
	sync
	sudo umount $(MOUNTDIR)
	sudo losetup -d ${USED_LOOPBACK}

limine:
	git clone https://github.com/limine-bootloader/limine.git --branch=v2.0-branch-binary --depth=1
	
	make -C limine

clean:
	make -C kernel clean
	rm -rf limine

qemu:
	qemu-system-x86_64 $(IMAGE)