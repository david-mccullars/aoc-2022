require_relative './solve'

EXAMPLE = <<-END
    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2
END

class SupplyStacks

  def initialize(text)
    top, middle, bottom = text.split(/([ 0-9]+)\n\n/)
    @stacks = parse_stacks(top.lines.to_a, width: middle.size)
    @moves = parse_moves(bottom)
  end

  def parse_stacks(lines, width:)
    ((1..width) % 4).map do |i|
      lines.map do |line|
        line[i]
      end - [" "]
    end
  end

  def parse_moves(text)
    text.scan(/^move (\d+) from (\d+) to (\d+)/).map(&:map_i)
  end

  def operate!(mode:)
    @moves.each do |num, i1, i2|
      removed = @stacks[i1-1].slice!(0, num)
      removed.reverse! if mode == 9000
      @stacks[i2-1] = removed + @stacks[i2-1]
    end
    @stacks.map(&:first).join
  end

end

solve_with_text(clazz: SupplyStacks, EXAMPLE => "CMZ") do |stacks|
  stacks.operate!(mode: 9000)
end

solve_with_text(clazz: SupplyStacks, EXAMPLE => "MCD") do |stacks|
  stacks.operate!(mode: 9001)
end
