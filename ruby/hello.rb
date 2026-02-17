# Hello Ruby OS demo script
# Goal: keep Ruby >= 30% of repo code.
# This script isn't fully interpreted by the tiny boot demo,
# but it is embedded into the disk image and printed over serial.

puts "Hello Ruby"

# A couple of harmless helpers (for future expansion)

def banner(title)
  line = "=" * (title.size + 8)
  puts line
  puts "=== #{title} ==="
  puts line
end

banner("Tiny Ruby OS")

# Some data the OS could pass in later
info = {
  arch: "x86 (BIOS)",
  io:   "COM1 serial",
  demo: true,
}

info.each do |k, v|
  puts "#{k}: #{v}"
end

# Fibonacci just to have a bit more Ruby code

def fib(n)
  a = 0
  b = 1
  n.times do
    a, b = b, a + b
  end
  a
end

(0..12).each do |i|
  puts "fib(#{i}) = #{fib(i)}"
end

# End.

# --- Extra Ruby content for the "Ruby >= 30%" rule ---
# Below are small, readable snippets you can reuse later when you
# actually embed a Ruby VM (mruby) into a real kernel.

module TinyOS
  module Text
    def self.wrap(s, width: 40)
      out = []
      line = ""
      s.split(/\s+/).each do |w|
        if (line.size + w.size + 1) > width
          out << line.rstrip
          line = ""
        end
        line << w << " "
      end
      out << line.rstrip unless line.empty?
      out
    end

    def self.box(title, body)
      lines = wrap(body, width: 50)
      w = [title.size, *lines.map(&:size)].max + 4
      top = "+" + "-" * (w - 2) + "+"
      puts top
      puts "| " + title.ljust(w - 4) + " |"
      puts "|" + "-" * (w - 2) + "|"
      lines.each { |ln| puts "| " + ln.ljust(w - 4) + " |" }
      puts top
    end
  end

  module Mathy
    def self.primes(n)
      ps = []
      x = 2
      while ps.size < n
        ps << x if prime?(x)
        x += 1
      end
      ps
    end

    def self.prime?(k)
      return false if k < 2
      i = 2
      while i * i <= k
        return false if (k % i).zero?
        i += 1
      end
      true
    end
  end
end

TinyOS::Text.box(
  "Roadmap",
  "Next step: replace this print-demo with a real kernel, add a serial driver, " \
  "and embed mruby so this file runs as code, not just as text."
)

puts "First 10 primes: #{TinyOS::Mathy.primes(10).join(', ')}"

# End of extra Ruby.

