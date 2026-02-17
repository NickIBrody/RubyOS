; mbr.asm - 512-byte MBR boot sector
BITS 16
ORG 0x7C00

start:
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

  ; Read stage2 (N sectors) from disk using CHS (works in QEMU for early sectors)
  ; DL = boot drive set by BIOS
  mov bx, 0x8000        ; ES:BX destination
  mov ax, 0x0000
  mov es, ax

  mov ah, 0x02          ; INT 13h - read sectors
  mov al, STAGE2_SECTORS
  mov ch, 0x00          ; cylinder 0
  mov dh, 0x00          ; head 0
  mov cl, 0x02          ; sector 2 (sector 1 is MBR)
  int 0x13
  jc disk_fail

  jmp 0x0000:0x8000

disk_fail:
  mov si, msg_fail
  call serial_puts
  hlt
  jmp $

; --- Serial COM1 (0x3F8) ---
serial_init:
  mov dx, 0x3F8 + 1
  mov al, 0x00
  out dx, al            ; Disable interrupts

  mov dx, 0x3F8 + 3
  mov al, 0x80
  out dx, al            ; Enable DLAB

  mov dx, 0x3F8 + 0
  mov al, 0x01
  out dx, al            ; Divisor low  (115200)

  mov dx, 0x3F8 + 1
  mov al, 0x00
  out dx, al            ; Divisor high

  mov dx, 0x3F8 + 3
  mov al, 0x03
  out dx, al            ; 8N1

  mov dx, 0x3F8 + 2
  mov al, 0xC7
  out dx, al            ; Enable FIFO, clear, 14-byte

  mov dx, 0x3F8 + 4
  mov al, 0x0B
  out dx, al            ; IRQs enabled, RTS/DSR set
  ret

serial_putc:
  ; AL = char
  push dx
.wait:
  mov dx, 0x3F8 + 5
  in  al, dx
  test al, 0x20
  jz .wait
  mov dx, 0x3F8
  pop dx
  out dx, al
  ret

serial_puts:
  ; SI -> zero-terminated string
  push ax
.next:
  lodsb
  test al, al
  jz .done
  call serial_putc
  jmp .next
.done:
  pop ax
  ret

msg_boot db "Boot OK\r\n",0
msg_fail db "Disk read failed\r\n",0

STAGE2_SECTORS EQU 16

times 510-($-$$) db 0
dw 0xAA55
