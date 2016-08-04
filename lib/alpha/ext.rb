class String
  def ansicolor(sym, brighten = false)
    "\033[#{{ yellow:  93,
              cyan:    96,
              grey:    90,
              magenta: 95,
              white:   97,
              blue:    94 }[sym] || 97}#{';1' if brighten}m#{self}\033[0m"
  end
  def ansi_grey() "\033[90m#{self}\033[0m" end
  def ansi_cyan() "\033[96m#{self}\033[0m" end
  def ansi_yellow() "\033[93m#{self}\033[0m" end
end

# class Array
#     # %w(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
# end
