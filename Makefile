IMAGE := MonkaOS.img
MOUNTDIR := img_mount

include mk/strings.mk

build: monka image

full: clean limine monka image qemu

monka:
	@make --no-print-directory -s --keep-going -C kernel

image:
	@printf "%b" "$(CREATING_COLOUR)Creating $(DISK_COLOUR)disk$(NO_COLOUR)\n"
	@chronic dd if=/dev/zero bs=1M count=0 seek=64 of=$(IMAGE)
	@chronic parted -s $(IMAGE) mklabel gpt
	
	@printf "%b" "$(GENERAL_DISK_COLOUR)Partitioning $(DISK_COLOUR)disk$(NO_COLOUR)\n"
	@chronic parted -s $(IMAGE) mkpart ESP fat32 2048s 100%
	@chronic parted -s $(IMAGE) set 1 esp on
	
	@printf "%b" "$(INSTALLING_COLOUR)Installing $(LIMINE_COLOUR)$(LIMINE_STRING) Bootsector$(NO_COLOUR)\n"
	@chronic ./limine/limine-install $(IMAGE)
	
	$(eval USED_LOOPBACK:=$(shell sudo losetup -Pf --show $(IMAGE)))
	
	@printf "%b" "$(CREATING_COLOUR)Creating $(FS_COLOUR)FAT32 fs$(NO_COLOUR)\n"
	@sudo chronic mkfs.fat -F 32 ${USED_LOOPBACK}p1
	
	@printf "%b" "$(GENERAL_DISK_COLOUR)Mounting $(DISK_COLOUR)disk$(NO_COLOUR)\n"
	@chronic mkdir -p $(MOUNTDIR)
	@sudo chronic mount ${USED_LOOPBACK}p1 $(MOUNTDIR)
	
	@printf "%b" "$(GENERAL_DISK_COLOUR)Copying $(FILE_COLOUR)files $(GENERAL_DISK_COLOUR)-> $(DISK_COLOUR)disk$(NO_COLOUR)\n"
	@sudo chronic mkdir -p $(MOUNTDIR)/EFI/BOOT
	@sudo chronic cp -v kernel/MonkaOS.elf limine.cfg limine/limine.sys $(MOUNTDIR)/
	@sudo chronic cp -v limine/BOOTX64.EFI $(MOUNTDIR)/EFI/BOOT/
	
	@printf "%b" "$(CLEANING_COLOUR)Cleaning up$(NO_COLOUR)\n"
	@chronic sync
	@sudo chronic umount $(MOUNTDIR)
	@sudo chronic losetup -d ${USED_LOOPBACK}

limine:
	@printf "%b" "$(DOWNLOADING_COLOUR)Downloading $(LIMINE_COLOUR)$(LIMINE_STRING)$(NO_COLOUR)\n"
	@git clone https://github.com/limine-bootloader/limine.git --branch=v2.0-branch-binary --depth=1 --quiet
	
	@printf "%b" "$(BUILDING_COLOUR)Building $(LIMINE_COLOUR)$(LIMINE_STRING)$(NO_COLOUR)\n"
	@make --no-print-directory -s -C limine

clean:
	@printf "%b" "$(DEL_COLOUR)Removing $(FILE_COLOUR)files$(NO_COLOUR)\n"
	@make --no-print-directory -s -C kernel clean
	@rm -rf limine

qemu:
	@chronic qemu-system-x86_64 $(IMAGE) -cpu qemu64,+la57 -machine q35 -nic user,model=e1000