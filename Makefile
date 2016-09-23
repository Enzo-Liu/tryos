OS := $(shell uname)

ifeq ($(OS), Linux)
define copy_to_fat12
	mkfs.msdos $1
	sudo mount -o loop $1 $2
	sudo cp $3 $2
	sudo umount $2
endef
endif
ifeq ($(OS), Darwin)
define copy_to_fat12
	disk=$$(hdiutil attach -nomount $1) && \
	mount_msdos $$disk $2 && \
	cp $3 $2 && \
	umount $$disk && \
	hdiutil detach $$disk
endef
endif

run: target/tryos.img
	qemu-system-x86_64 -boot a -drive format=raw,file=./target/tryos.img,index=0,if=floppy -curses

graphics: target/tryos.img
	qemu-system-x86_64 -boot a -drive format=raw,file=./target/tryos.img,index=0,if=floppy

target/tryos.img: target/tryos.sys target/bootloader.bin
	dd bs=512 count=2880 if=/dev/zero of=./target/tryos.img
	dd status=noxfer conv=notrunc if=./target/bootloader.bin of=./target/tryos.img
	mkdir -p ./target/tryos
	$(call copy_to_fat12, ./target/tryos.img, ./target/tryos/, ./target/tryos.sys)
	dd status=noxfer conv=notrunc if=./target/bootloader.bin of=./target/tryos.img

target/tryos.sys: target stage2/* include/*
	nasm -f bin -i./include/ -o ./target/tryos.sys ./stage2/stage2.asm

target/bootloader.bin: target boot/* include/*
	nasm -f bin -i./include/ -o ./target/bootloader.bin ./boot/bootloader.asm

target:
	mkdir -p ./target

clean:
	rm -rf ./target
