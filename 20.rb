require_relative './solve'

EXAMPLE = <<-END
1
2
-3
3
-2
0
4
END

# Like The Highlander, there can only be one!
class UniqueWrapper

  attr_reader :value

  def initialize(value)
    @value = value
  end

end

class GrovePositioningSystem

  def initialize(numbers)
    @numbers = numbers
  end

  def mix(times = 1.times, decryption_key: 1)
    base = @numbers.map { UniqueWrapper.new(_1 * decryption_key) }

    mixed = base.dup
    times.each do
      base.each do |unique|
        index = mixed.index(unique)
        mixed.delete_at(index)
        new_index = (index + unique.value) % mixed.size
        mixed.insert(new_index, unique)
      end
    end

    zero = mixed.index { |u| u.value == 0 }
    [1000, 2000, 3000].map do |offset|
      mixed[(zero + offset) % mixed.size].value
    end.sum
  end

end

solve_with_numbers(clazz: GrovePositioningSystem, EXAMPLE => 3) do |gps|
  gps.mix
end

solve_with_numbers(clazz: GrovePositioningSystem, EXAMPLE => 1623178306) do |gps|
  gps.mix(10.times, decryption_key: 811589153)
end
