require_relative './solve'

EXAMPLE = <<-END
30373
25512
65332
33549
35390
END

class TallTrees

  DIRECTIONS = %i[up down left right].freeze
  EDGE = :EDGE

  def initialize(trees)
    @trees = trees
    @sightlines = {}

    trees.keys.each do |tree|
      @sightlines[tree] = Hash.new(0)
      DIRECTIONS.each do |dir|
        add_sightline(tree, dir)
      end
    end
  end

  def add_sightline(tree, dir)
    (1..).each do |distance|
      tree2 = tree.adjacent(dir, distance: distance)
      h, h2 = @trees.values_at(tree, tree2)
      @sightlines[tree][h2 ? dir : EDGE] += 1
      return if h2.nil? || h2 >= h
    end
  end

  def visible_from_edge
    @trees.keys.count do |tree|
      @sightlines[tree][EDGE].positive?
    end
  end

  def most_scenic_score
    @trees.keys.map do |tree|
      @sightlines[tree].values_at(*DIRECTIONS).reduce(&:*)
    end.max
  end

end

solve_with_grid_of_numbers(clazz: TallTrees, EXAMPLE => 21) do |trees|
  trees.visible_from_edge
end

solve_with_grid_of_numbers(clazz: TallTrees, EXAMPLE => 8) do |trees|
  trees.most_scenic_score
end
