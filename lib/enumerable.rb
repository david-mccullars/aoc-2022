Enumerable.module_eval do

  def map_i
    map(&:to_i)
  end

  def map_s
    map(&:to_s)
  end

  def map_sym
    map(&:to_sym)
  end

  def each_with_counter(default: 0, &block)
    each_with_object(Hash.new { default }, &block)
  end

  def first!
    raise "Size is not 1: #{to_a.inspect}" if size != 1
    first
  end

  def index_by
    each_with_object({}) do |e, h|
      h[yield(e)] = e
    end
  end

end
