require_relative './solve'

EXAMPLE1 = <<-END
R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2
END

EXAMPLE2 = <<-END
R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20
END

class RopeBridge

  MAX_KNOT_DISTANCE = Math.sqrt(2.0)

  def initialize(lines)
    @instructions = lines.map(&:split)
    @tail_positions = Set.new
  end

  def simulate(knots:, display: false)
    rope = Array.new(knots) { Vector.zero(2) }
    @instructions.each do |dir, amount|
      amount.to_i.times do
        rope = adjust_rope(rope, dir)
        @tail_positions << rope.last
      end
    end
    to_image(display)
    @tail_positions.size
  end

  def adjust_rope(rope, dir)
    adjusted_head = rope.shift.adjacent(dir)
    rope.reduce([adjusted_head]) do |adjusted_rope, knot|
      distance = adjusted_rope.last - knot
      knot += distance.map { _1 <=> 0 } if distance.magnitude > MAX_KNOT_DISTANCE
      adjusted_rope << knot
    end
  end

  # For fun
  def to_image(file)
    return unless file

    row_range, col_range = Matrix[*@tail_positions.to_a].transpose.to_a.map do |a|
      Range.new(*a.minmax)
    end

    require 'chunky_png'
    png = ChunkyPNG::Image.new(col_range.size, row_range.size, ChunkyPNG::Color::BLACK)
    @tail_positions.each_with_index do |knot, i|
      x = knot[1] - col_range.begin
      y = knot[0] - row_range.begin
      blue = (255.0 * i / @tail_positions.size).to_i
      red = @tail_positions.size - blue
      #png[x, y] = ChunkyPNG::Color.rgba(red, 0, blue, 255)
      png[x, y] = ChunkyPNG::Color.rgba(red, 0, 0, 125 + blue / 2)
    end
    png.save(file, interlace: true)
  end

end

solve_with(RopeBridge, EXAMPLE1 => 13) do |bridge|
  bridge.simulate(knots: 2)
end

solve_with(RopeBridge, EXAMPLE2 => 36) do |bridge|
  d = ARGV.index('-d')
  bridge.simulate(knots: 10, display: (ARGV[d + 1] if d))
end
