require_relative './solve'

EXAMPLE = <<-END
2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8
END

class AssignmentPair

  def initialize(line)
    @pairs = line.split(',').map do |pair|
      Range.new(*pair.split('-').map_i)
    end
  end

  def overlap
    @pairs.reduce(&:&)
  end

  def fully_contains?
    @pairs.include?(overlap)
  end

  def any_overlap?
    overlap.any?
  end

end

solve_with_each(AssignmentPair, EXAMPLE => 2) do |pairs|
  pairs.count(&:fully_contains?)
end

solve_with_each(AssignmentPair, EXAMPLE => 4) do |pairs|
  pairs.count(&:any_overlap?)
end
