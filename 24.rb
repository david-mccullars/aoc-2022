require_relative './solve'

EXAMPLE = <<-END
#.######
#>>.<^<#
#.<..<<#
#>v.><>#
#<^v^^>#
######.#
END

class BlizzardBasin

  ELF_MOVEMENTS = [
    [0, 1],
    [1, 0],
    [0, 0],
    [-1, 0],
    [0, -1],
  ]

  extend WithMemoizedMethods
  include DijkstraFast::ShortestPath

  def initialize(lines)
    @walls = Set.new
    @blizzards_0 = {}
    empty = []

    lines.each_with_index do |line, row|
      line.chomp.chars.each_with_index do |c, col|
        case c
        when '#'
          @walls
        when '.'
          empty
        else
          @blizzards_0[c.to_sym] ||= []
        end << [row - 1, col - 1]
      end
    end

    @start, @end = empty.minmax   
    @blizzard_repeat = %i[^ > v <].zip(@walls.max * 2).to_h
    @maxrow, @maxcol = @walls.max.map { _1 - 1 }

    @walls << [@start[0] - 1, @start[1]]
    @walls << [@end[0] + 1, @end[1]]
  end

  def connections(u)
    r, c, t = u
    ELF_MOVEMENTS.each do |dr, dc|
      v = [r + dr, c + dc]
      next if @walls.include?(v) || blizzards(t + 1).include?(v)
      v << t + 1 unless v == @end
      yield v, 1
    end
  end

  def blizzards(time)
    @blizzard_repeat.reduce(Set.new) do |set, (dir, repeat)|
      set.merge(blizzards_for(dir, time % repeat))
    end
  end

  def blizzards_for(dir, time)
    return @blizzards_0[dir] if time == 0

    blizzards_for(dir, time - 1).map do |pos|
      r, c = pos
      case dir
      when :^
        [r == 0 ? @maxrow : r - 1, c]
      when :v
        [r == @maxrow ? 0 : r + 1, c]
      when :<
        [r, c == 0 ? @maxcol : c - 1]
      when :>
        [r, c == @maxcol ? 0 : c + 1]
      end
    end
  end

  memoize :blizzards
  memoize :blizzards_for

  def travel
    @start_time ||= 0
    @start_time += shortest_distance(@start + [@start_time], @end)
  ensure
    @start, @end = @end, @start
  end

end

solve_with(BlizzardBasin, EXAMPLE => 18) do |bb|
  bb.travel
end

solve_with(BlizzardBasin, EXAMPLE => 54) do |bb|
  bb.travel
  bb.travel
  bb.travel
end
