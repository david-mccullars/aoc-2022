require_relative './solve'
require 'facets'

EXAMPLE = <<-END
Sensor at x=2, y=18: closest beacon is at x=-2, y=15
Sensor at x=9, y=16: closest beacon is at x=10, y=16
Sensor at x=13, y=2: closest beacon is at x=15, y=3
Sensor at x=12, y=14: closest beacon is at x=10, y=16
Sensor at x=10, y=20: closest beacon is at x=10, y=16
Sensor at x=14, y=17: closest beacon is at x=10, y=16
Sensor at x=8, y=7: closest beacon is at x=2, y=10
Sensor at x=2, y=0: closest beacon is at x=2, y=10
Sensor at x=0, y=11: closest beacon is at x=2, y=10
Sensor at x=20, y=14: closest beacon is at x=25, y=17
Sensor at x=17, y=20: closest beacon is at x=21, y=22
Sensor at x=16, y=7: closest beacon is at x=15, y=3
Sensor at x=14, y=3: closest beacon is at x=15, y=3
Sensor at x=20, y=1: closest beacon is at x=15, y=3
END

class BeaconExclusionZone

  def initialize(lines)
    pairs = lines.map do |line|
      line.scan(/-*\d+/).map_i.each_slice(2).to_a
    end.to_h
    @beacons = pairs.values.uniq
    @sensors = pairs.map do |sensor, beacon|
      [sensor, manhattan(sensor, beacon)]
    end.to_h

    @is_example = @sensors.size < 20
    @interesting_row = @is_example ? 10 : 2000000
    @max_scan_range = @is_example ? 20 : 4000000
  end

  def manhattan(a, b)
    (a.first - b.first).abs + (a.last - b.last).abs
  end

  def scan_interesting_row
    beacons_on_row = @beacons.count { |_, y| y == @interesting_row }

    ranges = @sensors.filter_map do |sensor, beacon_distance|
      distance = beacon_distance - (@interesting_row - sensor[1]).abs
      (sensor[0] - distance .. sensor[0] + distance) if distance >= 0
    end

    Range.combine(*ranges).map(&:size).sum - beacons_on_row
  end

  def find_distress_signal
    x = Z3::Int("x")
    y = Z3::Int("y")
    signal = [x, y]
    solver = Z3::Solver.new

    @sensors.each do |sensor, beacon_distance|
      signal_distance = manhattan(signal, sensor)
      solver.assert(signal_distance > beacon_distance)
    end
    solver.assert(x >= 0)
    solver.assert(x <= @max_scan_range)
    solver.assert(y >= 0)
    solver.assert(y <= @max_scan_range)

    abort "Solution can't be found" unless solver.satisfiable?
    solver.model.map { |n, v| v.to_i }
  end

  def distress_signal_tuning_frequency
    x, y = find_distress_signal
    4000000 * x + y
  end

end

solve_with(BeaconExclusionZone, EXAMPLE => 26) do |zone|
  zone.scan_interesting_row
end

solve_with(BeaconExclusionZone, EXAMPLE => 56000011) do |zone|
  zone.distress_signal_tuning_frequency
end
