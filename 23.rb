require_relative './solve'

EXAMPLE = <<-END
....#..
..###.#
#...#.#
.#...##
#.###..
##.#.##
.#..#..
END

class UnstableDiffusion

  PRIORITIES = [
    :u, :ur, :ul,
    :d, :dr, :dl,
    :l, :ul, :dl,
    :r, :ur, :dr,
  ]

  def initialize(lines)
    @grid = Set.new
    lines.each_with_index do |line, row|
      line.chomp.chars.each_with_index do |c, col|
        @grid << [row, col] if c == '#'
      end
    end
    @priorities = PRIORITIES.dup
  end

  def take_turn
    move(propositions)
  ensure
    shift_priorities
    show_grid if DISPLAY
  end

  def propositions
    @grid.each_with_object({}) do |pos, options|
      available_moves = pos.adjacent(@priorities).map { _1 unless @grid.include?(_1) }
      next if available_moves.all?

      pos2 = available_moves.each_slice(3).detect(&:all?)&.first
      next unless pos2

      options[pos2] ||= []
      options[pos2] << pos
    end
  end

  def move(options)
    options.reject! { |_, elves| elves.size > 1 }
    return false if options.none?

    options.transform_values(&:first).each do |pos2, pos|
      @grid.delete(pos)
      @grid << pos2
    end
  end

  def shift_priorities
    3.times { @priorities << @priorities.shift }
  end

  # For fun!
  def show_grid
    rows = Range.new(*@grid.map(&:first).minmax)
    cols = Range.new(*@grid.map(&:last).minmax)
    rows.each do |row|
      puts cols.map { |col| @grid.include?([row, col]) ? '#' : '.' }.join
    end
    puts
  end

  def check_progress
    10.times { take_turn }

    h = @grid.map(&:first).minmax.reduce(:-) - 1
    w = @grid.map(&:last).minmax.reduce(:-) - 1

    h * w - @grid.size
  end

  def simulate_whole_process
    (1..).detect { !take_turn }
  end

end

DISPLAY = ARGV[0] == '-d'

solve_with(UnstableDiffusion, EXAMPLE => 110) do |ud|
  ud.check_progress
end

solve_with(UnstableDiffusion, EXAMPLE => 20) do |ud|
  ud.simulate_whole_process
end
