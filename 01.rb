require_relative './solve'

EXAMPLE = <<-END
1000
2000
3000

4000

5000
6000

7000
8000
9000

10000
END

class CalorieCounter

  def initialize(lines)
    @counts_by_elf = lines.slice_after(0).map(&:sum)
  end

  def maxsum(count = 1)
    @counts_by_elf.max(count).sum
  end

end

solve_with_numbers(clazz: CalorieCounter, EXAMPLE => 24000) do |counter|
  counter.maxsum
end

solve_with_numbers(clazz: CalorieCounter, EXAMPLE => 45000) do |counter|
  counter.maxsum(3)
end
