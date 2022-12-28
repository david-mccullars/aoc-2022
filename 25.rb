require_relative './solve'

EXAMPLE = <<-END
1=-0-2
12111
2=0=
21
2=01
111
20012
112
1=-1=
1-12
12
1=
122
END

SNAFU_TO_DECIMAL = {
  '2' => 2,
  '1' => 1,
  '0' => 0,
  '-' => -1,
  '=' => -2,
}

class String
  def snafu_to_i
    chars.map { SNAFU_TO_DECIMAL.fetch(_1) }.reverse.zip(0..).map do |n, p|
      n * 5 ** p
    end.sum
  end
end

class Integer
  def to_snafu
    s = self
    digits = []
    while s > 0
      d = ((s + 2) % 5) - 2
      s = (s - d) / 5
      digits.unshift(SNAFU_TO_DECIMAL.key(d))
    end
    digits.join
  end
end

solve(EXAMPLE => "2=-1=0") do |lines|
  lines.map(&:snafu_to_i).sum.to_snafu
end

puts "====== CLAIM THE FINAL GOLD STAR!!! ======"
