; stage2.asm - loaded by MBR at 0x0000:0x8000
BITS 16
ORG 0x8000

start2:
  cli
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, 0x7A00
  sti

  call serial_init

  mov si, msg_hello
  call serial_puts

  mov si, msg_ruby
  call serial_puts

  ; print embedded Ruby file
  mov si, ruby_start
  call serial_puts

  mov si, msg_done
  call serial_puts

.hang:
  hlt
  jmp .hang

; --- Serial COM1 routines (same as MBR) ---
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

msg_hello db "Hello Ruby\r\n",0
msg_ruby  db "--- ruby/hello.rb (embedded) ---\r\n",0
msg_done  db "\r\n--- end ---\r\n",0

ruby_start:
  incbin "ruby/hello.rb"
  db 0
