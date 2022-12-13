require_relative './solve'
require 'json'

EXAMPLE = <<-END
[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]
END

class Array

  alias :orig_cmp :<=>

  def <=>(other)
    other.is_a?(Integer) ? self <=> [other] : orig_cmp(other)
  end

end

class Integer

  alias :orig_cmp :<=>

  def <=>(other)
    other.is_a?(Array) ? [self] <=> other : orig_cmp(other)
  end

end

class DistressSignal

  D1 = [[2]]
  D2 = [[6]]

  def initialize(lines)
    @packets = lines.filter_map do |line|
      JSON.parse(line) unless line.empty?
    end
  end

  def correctly_ordered_pairs
    @packets.each_slice(2).map.with_index do |pair, i|
      pair == pair.sort ? i + 1 : 0
    end.sum
  end

  def decoder_key
    sorted = [D1, D2, *@packets].sort
    sorted.unshift :adjust_indices
    sorted.index(D1) * sorted.index(D2)
  end

end

solve_with(DistressSignal, EXAMPLE => 13) do |signal|
  signal.correctly_ordered_pairs
end

solve_with(DistressSignal, EXAMPLE => 140) do |signal|
  signal.decoder_key
end
