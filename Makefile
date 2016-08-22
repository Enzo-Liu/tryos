OS := $(shell uname)

run: target/tryos.img
	qemu-system-x86_64 -fda ./target/tryos.img -curses

target/tryos.img: target/stage2.img target/bootloader.bin
	dd bs=512 count=2880 if=/dev/zero of=./target/tryos.img
	mkdir -p ./target/tryos
ifeq ($(OS), Linux)
	mkfs.msdos ./target/tryos.img
	sudo mount -o loop ./target/tryos.img ./target/tryos
	sudo cp ./target/stage2.img ./target/tryos/tryos.sys
	sudo umount ./target/tryos
	dd status=noxfer conv=notrunc if=./target/bootloader.bin of=./target/tryos.img
endif
ifeq ($(OS), Darwin)
	dd status=noxfer conv=notrunc if=./target/bootloader.bin of=./target/tryos.img
	disk=$$(hdiutil attach -nomount ./target/tryos.img) && \
	mount_msdos $$disk ./target/tryos && \
	cp ./target/stage2.img ./target/tryos/tryos.sys && \
	umount $$disk && \
	hdiutil detach $$disk
endif

target/stage2.img: target
	nasm -f bin -o ./target/stage2.img ./stage2/stage2.asm

target/bootloader.bin: target
	nasm -f bin -o ./target/bootloader.bin ./boot/bootloader.asm

target:
	mkdir -p ./target

clean:
	rm -rf ./target
