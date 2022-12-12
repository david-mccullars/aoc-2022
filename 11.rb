require_relative './solve'

EXAMPLE = <<-END
Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1
END

class Monkey

  extend HasFormat

  has_format <<~MONKEY
    Monkey {{i:id}}:
      Starting items: {{csvi:items}}
      Operation: new = old {{operator}} {{operand}}
      Test: divisible by {{i:divisor}}
        If true: throw to monkey {{i:throw_when_true}}
        If false: throw to monkey {{i:throw_when_false}}
  MONKEY

  attr_reader :id, :inspections, :divisor

  def initialize
    @inspections = 0
  end

  def inspect_each_item
    @inspections += @items.size
    @items.each do |i|
      yield operate(i)
    end
    @items = []
  end

  def operate(i)
    i.send(@operator, @operand == "old" ? i : @operand.to_i)
  end

  def pass_recipient(i)
    i % @divisor == 0 ? @throw_when_true : @throw_when_false
  end

  def receive(i)
    @items << i
  end

end

class MonkeyInTheMiddle

  extend HasFormat

  has_format [Monkey]

  def initialize(monkeys)
    @monkeys = monkeys
    @relief = true
    @modulo ||= monkeys.map(&:divisor).reduce(&:*)
  end

  def without_relief
    @relief = false
    self
  end

  def play(rounds:)
    1.upto(rounds) do
      @monkeys.each do |monkey|
        monkey.inspect_each_item do |item|
          item = adjust_worry(item)
          pass(item, to: monkey.pass_recipient(item))
        end
      end
    end
    @monkeys.map(&:inspections).max(2).reduce(&:*)
  end

  def adjust_worry(item)
    item /= 3 if @relief
    item % @modulo
  end

  def pass(item, to:)
    @monkeys[to].receive(item)
  end

end

solve_with_format(MonkeyInTheMiddle, EXAMPLE => 10605) do |monkeys|
  monkeys.play(rounds: 20)
end

solve_with_format(MonkeyInTheMiddle, EXAMPLE => 2713310158) do |monkeys|
  monkeys.without_relief.play(rounds: 10_000)
end
