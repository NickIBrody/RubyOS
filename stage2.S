.intel_syntax noprefix
.code16
.global _start2

.section .text
_start2:
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

  mov si, ruby_start
  call serial_puts

  mov si, msg_done
  call serial_puts

1:
  hlt
  jmp 1b

# --- Serial COM1 routines ---
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

msg_hello: .asciz "Hello Ruby\r\n"
msg_ruby:  .asciz "--- ruby/hello.rb (embedded) ---\r\n"
msg_done:  .asciz "\r\n--- end ---\r\n"

ruby_start:
  .incbin "ruby/hello.rb"
  .byte 0
