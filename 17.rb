require_relative './solve'

EXAMPLE = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"

class PyroclasticFlow

  ROCKS = [
    Set[[0, 0], [1, 0], [2, 0], [3, 0]],         ####

                                                  #
    Set[[1, 0], [0, 1], [1, 1], [2, 1], [1, 2]], ###
                                                  #

                                                   #
    Set[[0, 0], [1, 0], [2, 0], [2, 1], [2, 2]],   #
                                                 ###

                                                 #
    Set[[0, 0], [0, 1], [0, 2], [0, 3]],         #
                                                 #
                                                 #

    Set[[0, 0], [1, 0], [0, 1], [1, 1]],         ##
                                                 ##
  ]

  def initialize(text)
    @jets = text.chars.map { _1 == '>' ? 1 : -1 }
    @fallen = Set[*Array.new(7) { [_1, 0] }] # Rock bottom
    @rock_count = 0
    @height = 0
    @rock_cursor = -1
    @jet_cursor = -1
    @memo = {}
  end

  def prove_accurate
    let_the_rocks_fall_until { @rock_count == 2022 }
  end

  def really_impress_the_elephants
    let_the_rocks_fall_until { pattern_detected?(1_000_000_000_000) }
  end

  def let_the_rocks_fall_until
    loop do
      fall!(next_rock)
      return @height if yield
    end
  end

  def fall!(rock)
    x, y = 2, @height + 4

    loop do
      x_shift = next_jet
      x += x_shift unless overlap?(rock, x + x_shift, y)

      break if overlap?(rock, x, y - 1)
      y -= 1
    end

    add!(rock, x, y)
  end

  def overlap?(rock, x, y)
    rock.any? do |dx, dy|
      !(0...7).include?(x + dx) || @fallen.include?([x + dx, y + dy])
    end
  end

  def add!(rock, x, y)
    rock.each { |i, j| @fallen << [x + i, y + j] }
    @rock_count += 1
    @height = @fallen.map(&:last).max
  end

  def next_rock
    @rock_cursor = (@rock_cursor + 1) % ROCKS.size
    ROCKS[@rock_cursor]
  end

  def next_jet
    @jet_cursor = (@jet_cursor + 1) % @jets.size
    @jets[@jet_cursor]
  end

  def pattern_detected?(desired_count)
    state = [@jet_cursor, @rock_cursor].hash
    return unless @memo[state]

    last_rock_count, last_height = @memo[state]
    rocks_to_add = @rock_count - last_rock_count
    height_to_add = @height - last_height
    return unless (desired_count - @rock_count) % rocks_to_add == 0

    @height += (desired_count - @rock_count) / rocks_to_add * height_to_add
  ensure
    @memo[state] = [@rock_count, @height]
  end

end

solve_with_text(clazz: PyroclasticFlow, EXAMPLE => 3068) do |flow|
  flow.prove_accurate
end

solve_with_text(clazz: PyroclasticFlow, EXAMPLE => 1514285714288) do |flow|
  flow.really_impress_the_elephants
end
