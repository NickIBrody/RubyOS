# RubyOS — Hello Ruby (Serial Boot Demo)

RubyOS is a tiny experimental bootable OS demo that prints **"Hello Ruby"** using BIOS serial output (COM1).

This project was created as a minimal step toward a Ruby-powered hobby OS, with the goal of keeping the boot code extremely small while still having Ruby code included in the system image.

---

## What it does

- Boots on x86 BIOS systems (MBR)
- Loads a second stage loader
- Prints text through serial (COM1)
- Includes a Ruby script (`ruby/hello.rb`) embedded into the image

Example output:
Boot OK Hello Ruby
---

## Why serial output?

Using VGA text mode would normally be the simplest solution, but it is not always reliable across different emulators and environments.

Serial output (COM1) is extremely minimal and stable, which makes it a perfect choice for early-stage OS development.

---

## Compromises and design decisions

This project is intentionally small and comes with several compromises:

### No real Ruby interpreter (yet)
Ruby code is currently stored as a payload and printed/embedded, but not actually executed.
Running Ruby inside a real OS requires either:
- embedding a full interpreter, or
- integrating a lightweight VM like **MRuby**

Both options increase the binary size and complexity significantly.

### No filesystem
There is no filesystem driver.  
The Ruby script is embedded directly into the disk image to keep the design simple.

### BIOS-only boot (MBR)
The boot process is classic BIOS/MBR.
UEFI support was avoided to reduce complexity and keep the project minimal.

### Minimal C / no libc
The system does not rely on a standard C library.
Everything is written in low-level assembly with direct hardware access.

---

## Build

Requirements:
- `as`
- `ld`
- `dd`
- `make`

Build:
```bash
make clean && make


# Run (QEMU)
qemu-system-i386 -hda hello_ruby_serial.img -nographic -serial mon:stdio

.
├── ruby/
│   └── hello.rb
├── mbr.S
├── stage2.S
├── Makefile
├── README.md
└── hello_ruby_serial.img
