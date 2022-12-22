require_relative './solve'

EXAMPLE = <<-END
        ...#
        .#..
        #...
        ....
...#.......#
........#...
..#....#....
..........#.
        ...#....
        .....#..
        .#......
        ......#.

10R5L5R10L4R5L5
END

class MonkeyMap

  DIRECTIONS = {
    right: [ 0,  1],
    down:  [ 1,  0],
    left:  [ 0, -1],
    up:    [-1,  0],
  }

  def initialize(lines)
    @instructions = lines.pop.split(/([RL])/).flatten.map do |i|
      i =~ /^\d+$/ ? i.to_i : i.to_sym
    end
    lines.pop

    @map = {}
    lines.each_with_index do |line, row|
      line.chomp.chars.each_with_index do |char, col|
        @map[[row + 1, col + 1]] = char unless char == ' '
      end
    end

    @pos = row_min(1)
    @dir = :right
  end

  def is_cube
    @cube = true
    self
  end

  def follow_path
    @instructions.each do |instruction|
      case instruction
      when :R
        turn(1)
      when :L
        turn(-1)
      else
        move(instruction)
      end
    end
    score
  end

  def turn(change)
    @dir = DIRECTIONS.keys[(dir_index + change) % 4]
  end

  def move(amount)
    amount.times do
      dr, dc = DIRECTIONS.fetch(@dir)
      move_to(@pos[0] + dr, @pos[1] + dc) or return
    end
  end

  def move_to(r, c, dir=nil)
    case @map[[r, c]]
    when nil
      move_to(*wrap_around)
    when '.'
      @dir = dir if dir
      @pos = [r, c]
    when '#'
      return
    end
  end

  def wrap_around
    @cube ? wrap_around_cube : wrap_around_flat
  end

  def wrap_around_flat
    r, c = @pos
    case @dir
    when :right
      row_min(r)
    when :left
      row_max(r)
    when :up
      col_max(c)
    when :down
      col_min(c)
    end
  end

  def row_minmax
    @row_minmax ||= @map.keys.group_by(&:first).transform_values do
      _1.map(&:last).minmax
    end
  end

  def row_min(row)
    [row, row_minmax[row].first]
  end

  def row_max(row)
    [row, row_minmax[row].last]
  end

  def col_minmax
    @col_minmax ||= @map.keys.group_by(&:last).transform_values do
      _1.map(&:first).minmax
    end
  end

  def col_min(col)
    [col_minmax[col].first, col]
  end

  def col_max(col)
    [col_minmax[col].last, col]
  end

  # ONLY WORKS FOR REAL INPUT, NOT EXAMPLE
  def wrap_around_cube
    r, c = @pos
    case @dir
    when :right
      case c
      when 50
        [150, 50 + (r - 150), :up]
      when 150
        [151 - r, 100, :left]
      else
        r > 100 ? [51 - (r - 100), 150, :left] : [50, 100 + (r - 50), :up]
      end

    when :left
      if c == 1
        r > 150 ? [1, r - 150 + 50, :down] : [1 + (150 - r), 51, :right]
      else
        r > 50 ? [101, r - 50, :down] : [151 - r, 1, :right]
      end

    when :down
      case r
      when 50
        [c - 50, 100, :left]
      when 150
        [c + 100, 50, :left]
      else
        [1, c + 100, :down]
      end

    when :up
      if r == 1
        c > 100 ? [200, c - 100, :up] : [c + 100, 1, :right]
      else
        [c + 50, 51, :right]
      end
    end
  end

  def score
    1000 * @pos[0] + 4 * @pos[1] + dir_index
  end

  def dir_index
    DIRECTIONS.keys.index(@dir)
  end

end

solve_with(MonkeyMap, EXAMPLE => 6032) do |map|
  map.follow_path
end

solve_with(MonkeyMap) do |map|
  map.is_cube.follow_path
end
