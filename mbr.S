.intel_syntax noprefix
.code16
.global _start

.section .text
_start:
  cli
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, 0x7C00
  sti

  call serial_init
  mov si, msg_boot
  call serial_puts

  # Read stage2 (STAGE2_SECTORS sectors) from CHS 0/0/2 into 0000:8000
  mov bx, 0x8000
  xor ax, ax
  mov es, ax

  mov ah, 0x02
  mov al, STAGE2_SECTORS
  mov ch, 0x00
  mov dh, 0x00
  mov cl, 0x02
  int 0x13
  jc disk_fail

  ljmp 0x0000, 0x8000

disk_fail:
  mov si, msg_fail
  call serial_puts
  hlt
  jmp .

# --- Serial COM1 ---
serial_init:
  mov dx, 0x3F8 + 1
  mov al, 0x00
  out dx, al

  mov dx, 0x3F8 + 3
  mov al, 0x80
  out dx, al

  mov dx, 0x3F8 + 0
  mov al, 0x01
  out dx, al

  mov dx, 0x3F8 + 1
  mov al, 0x00
  out dx, al

  mov dx, 0x3F8 + 3
  mov al, 0x03
  out dx, al

  mov dx, 0x3F8 + 2
  mov al, 0xC7
  out dx, al

  mov dx, 0x3F8 + 4
  mov al, 0x0B
  out dx, al
  ret

serial_putc:
  # AL = char
  push dx
1:
  mov dx, 0x3F8 + 5
  in  al, dx
  test al, 0x20
  jz 1b
  mov dx, 0x3F8
  pop dx
  out dx, al
  ret

serial_puts:
  push ax
1:
  lodsb
  test al, al
  jz 2f
  call serial_putc
  jmp 1b
2:
  pop ax
  ret

msg_boot: .asciz "Boot OK\r\n"
msg_fail: .asciz "Disk read failed\r\n"

.equ STAGE2_SECTORS, 16

# Pad MBR to 512 bytes and add signature
.org 510
.word 0xAA55
