require_relative './solve'

EXAMPLE = <<-END
498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9
END

Array.class_eval do
  alias :x :first
  alias :y :last
end

class RegolithReservoir

  SAND_SOURCE = [500, 0]

  def initialize(lines)
    @grid = {}

    lines.map do |line|
      line.scan(/\d+/).map_i.each_slice(2).each_cons(2).map do |p1, p2|
        fill_with_rock(p1, p2)
      end
    end

    @rock_bottom = @grid.keys.map(&:y).max
  end

  def with_floor(distance:)
    @floor = @rock_bottom + distance
    self
  end

  def fill_with_rock(p1, p2)
    (p1.x .. p2.x).abs.each do |x|
      (p1.y .. p2.y).abs.each do |y|
        @grid[[x, y]] = :rock
      end
    end
  end

  def fill_with_sand
    tile_stack = [SAND_SOURCE]

    until sand_clogged? || into_the_abyss?(tile_stack.last)
      empty_tile = next_empty_tile(tile_stack.last)

      if empty_tile && !at_floor?(empty_tile)
        tile_stack << empty_tile
      else
        @grid[tile_stack.pop] = :sand
      end
    end

    @grid.values.grep(:sand).size
  end

  def next_empty_tile(tile)
    x, y = tile
    [[x, y+1], [x-1, y+1], [x+1, y+1]].detect do |tile2|
      @grid[tile2].nil?
    end
  end

  def sand_clogged?
    @floor && @grid[SAND_SOURCE]
  end

  def into_the_abyss?(tile)
    !@floor && tile.y >= @rock_bottom
  end

  def at_floor?(tile)
    @floor == tile.y
  end

end

solve_with(RegolithReservoir, EXAMPLE => 24) do |reservoir|
  reservoir.fill_with_sand
end

solve_with(RegolithReservoir, EXAMPLE => 93) do |reservoir|
  reservoir.with_floor(distance: 2).fill_with_sand
end
