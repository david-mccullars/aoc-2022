require_relative './solve'
require 'parallel'

EXAMPLE = <<-END
Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
END

class HillClimbing

  include DijkstraFast::ShortestPath
  include ImageHelper

  def initialize(grid)
    grid[@start = grid.key('S')] = 'a'
    grid[@end = grid.key('E')] = 'z'
    @grid = grid.transform_values { _1.ord - 'a'.ord }
  end

  def connections(u)
    u.orthogonally_adjacent.each do |v|
      yield v, 1 if @grid[v] && @grid[v] <= @grid[u] + 1
    end
  end

  def shortest
    distance, path = shortest_path(@start, @end)
    to_image(path)
    distance
  end

  def overall_shortest
    possible_starts = @grid.select { |_, v| v.zero? }.keys
    show_progress = possible_starts.size > 10
    Parallel.map(possible_starts, progress: show_progress) do |alt_start|
      shortest_distance(alt_start, @end) rescue Float::INFINITY
    end.min
  end

  # For fun
  def to_image(path)
    d = ARGV.index("-d")
    file = ARGV[d + 1] if d
    return unless file

    image = overlay_images(
      expand_image(
        grid_to_pixels(@grid.transform_values { |h| Colors::TERRAIN.fetch(h) }),
        factor: 9,
      ),
      expand_image(
        path_to_pixels(path.map { |y, x| [y * 3, x * 3] }),
        factor: 3,
      ),
    )

    render_image(image, file: file)
  end

end

solve_with_grid_of_letters(clazz: HillClimbing, EXAMPLE => 31) do |hill|
  hill.shortest
end

solve_with_grid_of_letters(clazz: HillClimbing, EXAMPLE => 29) do |hill|
  hill.overall_shortest
end
