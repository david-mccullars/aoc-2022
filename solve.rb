require 'bundler'
require 'singleton'
require 'set'
Bundler.require
Dir['lib/**/*.rb'].sort.each { |f| load(f) }

#########################################################################

prev_caller = caller.reject { |line| line.start_with?(__FILE__) }[0]
abort "Can not determine day: #{prev_caller}" unless prev_caller =~ %r{(\d+)[a-z]*\.rb:}
day = $1
AoC.define_singleton_method(:day) { day.to_i }

#########################################################################

def example(data, suffix)
  case suffix
  when :lines
    data.lines(chomp: true)
  when :text
    data.chomp
  when :numbers
    data.lines.map_i
  when :number
    data.lines.first.to_i
  else
    abort "Invalid example suffix: #{suffix.inspect}"
  end
end

def input(suffix)
  AoC.handle_name(AoC.get_year, "DAY#{AoC.day}_#{suffix}") or abort "Invalid suffix #{suffix.inspect}"
end

def classify(data, clazz)
  clazz ? mark_example(clazz.new(data), data) : data
end

def mark_example(obj, source = nil)
  is_example = source.nil? || source.instance_variable_get(:@is_example)
  obj.instance_variable_set(:@is_example, is_example) if is_example
  obj
end

def solve(suffix = :lines, clazz: nil, **examples)
  @letter = @letter ? (@letter.ord + 1).chr : 'A'
  examples.each do |input, expected_result|
    actual_result = yield mark_example(classify(example(input, suffix), clazz))
    if expected_result != actual_result
      puts "========================== #{@letter} =========================="
      abort "Expected result (#{expected_result}) does not equal actual result (#{actual_result.inspect})"
    end
  end

  start_time = Time.now.to_f
  result = yield classify(input(suffix), clazz)
  duration = (Time.now.to_f - start_time) * 1000.0
  puts "Part #{@letter.ord - 'A'.ord + 1}: \033[1m#{result}\033[0m (#{duration.round(1)}ms)"

  if already_accepted = SolutionPoster.instance.accepted_solution(@letter)
    if already_accepted != result.to_s
      abort "Accepted result (#{already_accepted}) no longer matches actual result (#{result.inspect})"
    end
  else
    SolutionPoster.instance.post_solution(result, @letter) unless already_accepted
  end
end

%i[lines text numbers number].each do |suffix|
  define_method("solve_with_#{suffix}") do |**opts, &block|
    solve(suffix, **opts, &block)
  end
end

def solve_with_line_of_numbers(clazz: nil, **opts)
  solve(:text, **opts) do |text|
    yield classify(text.split(/\s*,\s*/).map_i, clazz)
  end
end

def solve_with_grouped_lines(clazz: nil, **opts)
  solve(:text, **opts) do |text|
    yield classify(text.split(/\n\n/).map { |g| g.lines.map(&:chomp) }, clazz)
  end
end

def solve_with_grid_of_numbers(clazz: nil, **opts)
  solve_with_grid_of_letters(**opts) do |data|
    yield classify(data.transform_values(&:to_i), clazz)
  end
end

def solve_with_grid_of_letters(clazz: nil, **opts)
  solve(**opts) do |lines|
    grid = {}
    lines.each_with_index do |line, row|
      line.chars.each_with_index do |c, col|
        grid[[row, col]] = c
      end
    end
    yield classify(grid, clazz)
  end
end

def solve_with_format(clazz, **opts)
  case clazz
  when HasFormat, HasFormat::Parser
    solve(:text, **opts) do |text|
      yield mark_example(clazz.parse(text), text)
    end
  when Array
    solve(:text, **opts) do |text|
      parser = HasFormat::ArrayParser.new(*clazz)
      yield mark_example(parser.parse(text), text)
    end
  else
    raise ArgumentError, "Class #{clazz} can not be parsed by format"
  end
end

def solve_with(clazz, *args, **opts)
  solve(*args, **opts) do |data|
    yield classify(data, clazz)
  end
end

def solve_with_each(clazz, *args, **opts)
  solve(*args, **opts) do |data|
    yield data.map { |d| classify(d, clazz) }
  end
end
