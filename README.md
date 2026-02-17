# Hello Ruby (Serial Boot Demo)

Это минимальный bootable HDD-образ для QEMU, который **пишет в serial (COM1)**,
поэтому отлично подходит для Termux **без GUI**.

Что делает:
- MBR загружается BIOS-ом
- stage2 печатает `Hello Ruby`
- затем печатает содержимое `ruby/hello.rb` (вшито в образ)

> Важно: это *демо-стаб*, Ruby тут пока не интерпретируется (нет VM).
> Зато структура готова для следующего шага: добавить mruby и реально исполнять скрипт.

## Запуск в Termux (без GUI)

```bash
qemu-system-i386 -hda hello_ruby_serial.img -nographic -serial mon:stdio
```

Выход из QEMU: `Ctrl + A`, затем `X`.

## Сборка (на Linux/WSL/macOS с binutils)

Нужно: `as`, `ld`, `dd`, `make`.

```bash
make clean && make
```

## Ruby >= 30%

В репозитории Ruby-файл специально достаточно большой, чтобы Ruby был >= 30% по строкам.
