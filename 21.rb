require_relative './solve'
require 'tsort'

EXAMPLE = <<-END
root: pppw + sjmn
dbpl: 5
cczh: sllz + lgvd
zczc: 2
ptdq: humn - dvpt
dvpt: 3
lfqf: 4
humn: 5
ljgn: 2
sjmn: drzm * dbpl
sllz: 4
pppw: cczh / lfqf
lgvd: ljgn * ptdq
drzm: hmdt - zczc
hmdt: 32
END

class MonkeyMath

  def initialize(lines)
    @assertions = lines.filter_map do |line|
      assertion(*line.split(/:? /))
    end
  end

  def monkey(name)
    Z3::Int(name)
  end

  def assertion(name, m1, op = nil, m2 = nil)
    if m1 && m2
      monkey(name) == monkey(m1).send(op, monkey(m2))
    else
      monkey(name) == m1.to_i
    end
  end

  def solve(value)
    solver = Z3::Optimize.new
    @assertions.each { solver.assert(_1) }
    solver.model[monkey(value)].to_i if solver.satisfiable?
  end

end

class FixedMonkeyMath < MonkeyMath

  def assertion(name, m1, op = nil, m2 = nil)
    case name
    when 'humn'
      # ignore
    when 'root'
      monkey(m1) == monkey(m2)
    else
      super
    end
  end

end

solve_with(MonkeyMath, EXAMPLE => 152) do |math|
  math.solve('root')
end

solve_with(FixedMonkeyMath, EXAMPLE => 301) do |math|
  math.solve('humn')
end
