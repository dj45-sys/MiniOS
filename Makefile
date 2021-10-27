# sudo apt-get install g++ binutils libc6-dev-i386
# sudo apt-get install VirtualBox grub-legacy xorriso

%.o: 
	gcc -m32 -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore -c Kernel.cpp -o Kernel.bin

%.o: %.s
	as --32 -o $@ $<

Kernel.bin:
	ld -melf_i386 -T linker.ld -o loader.o kernel.bin

Kernel.iso: Kernel.bin
	mkdir iso
	mkdir iso/boot
	mkdir iso/boot/grub
	cp Kernel.bin iso/boot/Kernel.bin
	echo 'set timeout=0'                      > iso/boot/grub/grub.cfg
	echo 'set default=0'                     >> iso/boot/grub/grub.cfg
	echo ''                                  >> iso/boot/grub/grub.cfg
	echo 'menuentry "My Operating System" {' >> iso/boot/grub/grub.cfg
	echo '  multiboot /boot/Kernel.bin'    >> iso/boot/grub/grub.cfg
	echo '  boot'                            >> iso/boot/grub/grub.cfg
	echo '}'                                 >> iso/boot/grub/grub.cfg
	grub-mkrescue --output=Kernel.iso iso
	rm -rf iso

run: Kernel.iso
	(killall VirtualBoxVM && sleep 1) || true
	/usr/lib/virtualbox/VirtualBoxVM --comment "My Operating System" --startvm  &

install: Kernel.bin
	sudo cp $< /boot/Kernel.bin