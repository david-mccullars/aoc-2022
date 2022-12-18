require_relative './solve'

EXAMPLE = <<-END
2,2,2
1,2,2
3,2,2
2,1,2
2,3,2
2,2,1
2,2,3
2,2,4
2,2,6
1,2,5
3,2,5
2,1,5
2,3,5
END

class BoilingBoulders

  ADJACENT = [
    [ 0,  0, -1],
    [ 0,  0,  1],
    [ 0, -1,  0],
    [ 0,  1,  0],
    [-1,  0,  0],
    [ 1,  0,  0],
  ]

  def initialize(lines)
    @cubes = lines.map do |line|
      line.split(',').map_i
    end
    @cubes = Set[*@cubes]
  end

  def count_faces(cubes = @cubes)
    shared_faces = cubes.sum do |a|
      adjacent(a).count do |b|
        cubes.include?(b)
      end
    end

    cubes.size * 6 - shared_faces
  end

  def adjacent(location)
    x, y, z = location
    ADJACENT.map do |dx, dy, dz|
      [x + dx, y + dy, z + dz]
    end
  end

  def in_region?(location)
    region.zip(location).all? do |range, i|
      range.include?(i)
    end
  end

  def region
    @region ||= 3.times.map do |i|
      min, max = @cubes.map { |c| c[i] }.minmax
      Range.new(min - 1, max + 1)
    end
  end

  def interior
    @interior ||= all - exterior - @cubes
  end

  def exterior
    return @exterior if defined? @exterior

    @exterior = Set.new
    to_visit = [region.map(&:begin)]

    while u = to_visit.shift
      @exterior << u
      adjacent(u).each do |v|
        to_visit << v if in_region?(v) &&
                         !@cubes.include?(v) &&
                         !@exterior.include?(v) &&
                         !to_visit.include?(v)
      end
    end

    @exterior
  end

  def all
    @all ||= Set.new.tap do |set|
      region.map(&:to_a).reduce(&:product).each do |((x, y), z)|
        set << [x, y, z]
      end
    end
  end

end

solve_with(BoilingBoulders, EXAMPLE => 64) do |bb|
  bb.count_faces
end

solve_with(BoilingBoulders, EXAMPLE => 58) do |bb|
  bb.count_faces - bb.count_faces(bb.interior)
end
