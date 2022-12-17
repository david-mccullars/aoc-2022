require_relative './solve'

EXAMPLE = <<-END
Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
END

class Valve < Struct.new(:name, :flow_rate, :tunnels)

  include Comparable

  extend HasFormat
  has_format "Valve {{name}} has flow rate={{i:flow_rate}}; tunnels? leads? to valves? {{csv:tunnels}}"

  def <=>(other)
    # ORDER BY flow_rate DESC, name ASC
    value = other.flow_rate <=> flow_rate
    value.zero? ? name <=> other.name : value
  end

end

class ProboscideaVolcanium

  extend Parameterizable
  extend WithMemoizedMethods
  extend HasFormat
  has_format [Valve]

  def initialize(valves)
    # Ensure that start_valve is last among valves with positive flow rate
    # The rest are only needed to calculate distance between valves
    valves.sort!

    # Assign each valve a numeric id rather than use its name
    @valve_ids = valves.map(&:name).map.with_index.to_h

    @start_valve = @valve_ids.fetch("AA")
    @all_valves_bitset = (1 << @start_valve) - 1
    @flow_rates = valves.map(&:flow_rate)

    build_distances(valves)
    build_max_flows
  end

  # Use Floyd–Warshall algorithm to determine shortest distance
  # between every pair of valves
  def build_distances(valves)
    @distances = Array.new(valves.size) { Array.new(valves.size) { Float::INFINITY } }

    valves.each_with_index do |v, i|
      @distances[i][i] = 0
      @valve_ids.values_at(*v.tunnels).each do |j|
        @distances[i][j] = 1
      end
    end

    (0...valves.size).to_a.permutation(3) do |i, j, k|
      alt_dist = @distances[k][i] + @distances[i][j]
      @distances[k][j] = alt_dist if alt_dist < @distances[k][j]
    end
  end

  # For each combination of valves that I might open, what is the maximum
  # flow I would achieve, regardless of how or when I open them?
  def build_max_flows
    max_flows_at = {}
    @max_flows = {}
    queue = [[0, @start_valve, minutes_available]]

    while state = queue.shift
      open_valves, valve, time = state

      new_flow = max_flows_at[state] || 0
      new_flow += @flow_rates[valve] * time

      @start_valve.times do |valve2|
        # Skip if valve2 already open
        next unless open_valves & (1 << valve2) == 0

        # Skip if there isn't enough time left to reach valve2 from valve
        # (AND turn valve2 on which costs an extra minute)
        distance = @distances[valve][valve2] + 1
        next if distance >= time

        new_state = [open_valves | (1 << valve2), valve2, time - distance]
        if max_flows_at.key?(new_state)
          max_flows_at[new_state] = new_flow if new_flow > max_flows_at[new_state]
        else
          queue << new_state
          max_flows_at[new_state] = new_flow
        end
      end

      @max_flows[open_valves] = new_flow if new_flow > @max_flows[open_valves].to_i 
    end
  end

  # For each combination of valves that I might be assigned, what is the maximum
  # flow I could achieve by opening some subset of them? As a simple example,
  # suppose I have time to open either A or B but not both. Then if I'm assigned
  # both A & B, I'll want to choose the maximum of the two.
  def max_flow_per_assignment
    max_flow_per_assignment = Array.new(@all_valves_bitset) { 0 }

    (@all_valves_bitset + 1).times do |assignment|
      max_flow = @max_flows[assignment].to_i # What if I open everything I'm assigned?
      @start_valve.times do |valve|
        # Can I achieve a higher flow if I skip opening this valve?
        assignment2 = assignment ^ (1 << valve)
        if assignment2 < assignment && max_flow_per_assignment[assignment2] > max_flow
          max_flow = max_flow_per_assignment[assignment2]
        end
      end
      max_flow_per_assignment[assignment] = max_flow
    end

    max_flow_per_assignment
  end

  def max_pressure_solo
    @max_flows.values.max
  end

  def max_pressure_with_an_elephant_friend
    max = max_flow_per_assignment
    @all_valves_bitset.times.map do |my_assignment|
      elephant_assignment = @all_valves_bitset - my_assignment
      max[my_assignment] + max[elephant_assignment]
    end.max
  end

end

solve_with_format(ProboscideaVolcanium[minutes_available: 30], EXAMPLE => 1651) do |pv|
  pv.max_pressure_solo
end

solve_with_format(ProboscideaVolcanium[minutes_available: 26], EXAMPLE => 1707) do |pv|
  pv.max_pressure_with_an_elephant_friend
end
