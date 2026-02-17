IMG=hello_ruby_serial.img

MBR_ELF=mbr.elf
STAGE2_ELF=stage2.elf
MBR_BIN=mbr.bin
STAGE2_BIN=stage2.bin

ASFLAGS=--32
LDFLAGS=-m elf_i386

all: $(IMG)

$(MBR_ELF): mbr.S
	as $(ASFLAGS) $< -o $@

$(STAGE2_ELF): stage2.S ruby/hello.rb
	as $(ASFLAGS) $< -o $@

$(MBR_BIN): $(MBR_ELF)
	ld $(LDFLAGS) -Ttext 0x7C00 --oformat binary -o $@ $<

$(STAGE2_BIN): $(STAGE2_ELF)
	ld $(LDFLAGS) -Ttext 0x8000 --oformat binary -o $@ $<

$(IMG): $(MBR_BIN) $(STAGE2_BIN)
	dd if=/dev/zero of=$(IMG) bs=1M count=8 status=none
	dd if=$(MBR_BIN) of=$(IMG) conv=notrunc status=none
	dd if=$(STAGE2_BIN) of=$(IMG) bs=512 seek=1 conv=notrunc status=none

run: $(IMG)
	qemu-system-i386 -hda $(IMG) -nographic -serial mon:stdio

clean:
	rm -f $(IMG) $(MBR_ELF) $(STAGE2_ELF) $(MBR_BIN) $(STAGE2_BIN)
