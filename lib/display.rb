module Display

  ON  = "#"
  OFF = "."

  FANCY_ON  = "⬛️"
  FANCY_OFF = "⬜️"

  LETTERS = File.read(File.expand_path("display.txt", __dir__)).
                 lines.map(&:chomp).
                 each_slice(7).map { |a| a.first(6) }.
                 zip("A".."Z").to_h

  def parsed_display
    lines = display.lines.map(&:chomp)
    cols = lines.first.size
    abort "Expected columns to be divisible by 5 but got #{cols}" unless cols % 5 == 0
    abort "Expected 6 rows but only got #{lines.size}" unless lines.size == 6

    lines.map do |row|
      row.chars.each_slice(5).map(&:join)
    end.transpose.map do |letter|
      LETTERS[letter] or abort "Can not find the following letter:\n\n#{letter.join("\n")}"
    end.join
  end

  def fancy_display
    cols = display.lines.first.size
    io = StringIO.new
    io.puts
    io.puts FANCY_OFF * cols
    display.gsub(ON, FANCY_ON).gsub(OFF, FANCY_OFF).lines.each do |line|
      io.puts "#{FANCY_OFF}#{line.chomp}"
    end
    io.puts FANCY_OFF * cols
    io.puts
    io.string
  end

end
