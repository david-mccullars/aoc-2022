Math.module_eval do

  #
  # Fibonacci is defined as:
  #   F(n) = F(n-2) + F(n-1)
  #   F(0) = 1
  #   F(-n) = 0
  #
  def self.fibonacci(n)
    return 0 if n < 0
    @fibonacci ||= [1]
    @fibonacci[n] ||= fibonacci(n - 2) + fibonacci(n - 1)
  end

  #
  # Tribonacci is defined as:
  #   T(n) = T(n-3) + T(n-2) + T(n-1)
  #   T(0) = 1
  #   T(-n) = 0
  #
  def self.tribonacci(n)
    return 0 if n < 0
    @tribonacci ||= [1]
    @tribonacci[n] ||= tribonacci(n - 3) + tribonacci(n - 2) + tribonacci(n - 1)
  end

  #
  # We can generalize this to any recursion quantity "m" via:
  #   G(n, m) = G(n-m, m) + G(n-m+1, m) + ... + G(n-1, m)
  #   G(0, m) = 1
  #   G(-n, m) = 0
  #
  # In this way we can redefine Fib/Trib as:
  #   F(n) = G(n, 2)
  #   T(n) = G(n, 3)
  #
  def self.m_bonacci(n, m)
    return 0 if n < 0
    @n_bonacci ||= {}
    @n_bonacci[m] ||= [1]
    @n_bonacci[m][n] ||= m.times.sum do |i|
      m_bonacci(n - i - 1, m)
    end
  end

  # We can expand our generalization even further by
  # accepting N different recursion quantities:
  #   M(*m) = m.last.times { m.pop ? M(*m) : 0 }.sum
  #   M() = 1
  #
  # In this way we can redefine the original generalization as:
  #   G(n, m) = M(Array.new(n) { m })
  #   F(n) = M(*Array.new(n) { 2 })
  #   T(n) = M(*Array.new(n) { 3 })
  def self.variable_m_bonacci(*m)
    return 1 if m.empty?
    @variable_m_bonacci ||= {}
    @variable_m_bonacci[m.dup] ||= m.last.times.sum do |i|
      m.pop ? variable_m_bonacci(*m) : 0
    end
  end

end

__END__

p [Math.fibonacci(2), Math.m_bonacci(2, 2), Math.variable_m_bonacci(*Array.new(2) { 2 })]
p [Math.fibonacci(3), Math.m_bonacci(3, 2), Math.variable_m_bonacci(*Array.new(3) { 2 })]
p [Math.fibonacci(15), Math.m_bonacci(15, 2), Math.variable_m_bonacci(*Array.new(15) { 2 })]

p [Math.tribonacci(2), Math.m_bonacci(2, 3), Math.variable_m_bonacci(*Array.new(2) { 3 })]
p [Math.tribonacci(3), Math.m_bonacci(3, 3), Math.variable_m_bonacci(*Array.new(3) { 3 })]
p [Math.tribonacci(15), Math.m_bonacci(15, 3), Math.variable_m_bonacci(*Array.new(15) { 3 })]

if ARGV.size > 0
  p Math.variable_m_bonacci(*ARGV.map_i)
end
