require_relative './solve'

EXAMPLE = <<-END
vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw
END

PRIORITIES = ('a'..'z').to_a + ('A'..'Z').to_a

def priority(items)
  item = items.reduce(&:&).first!
  PRIORITIES.index(item) + 1
end

solve(EXAMPLE => 157) do |lines|
  lines.map do |line|
    priority(line.chars.each_slice(line.size/2))
  end.sum
end

solve(EXAMPLE => 70) do |lines|
  lines.each_slice(3).flat_map do |group|
    priority(group.map(&:chars))
  end.sum
end
