module WithMemoizedMethods

  def memoize(name, debug: false)
    orig_name = :"__unmemoized_#{name}__"
    alias_method orig_name, name

    if debug
      define_method(name) do |*args|
        @memoized_method_calls ||= {}
        @memoized_method_calls[name] ||= {}
        @memoized_method_stats ||= {}
        @memoized_method_stats[name] ||= [0, 0]
        cache = @memoized_method_calls[name]

        if cache.key?(args)
          @memoized_method_stats[name][0] += 1
          cache[args]
        else
          @memoized_method_stats[name][1] += 1
          cache[args] = send(orig_name, *args)
        end
      end

      define_method("#{name}_stats") do
        hits, miss = @memoized_method_stats&.fetch(name, nil)
        if hits && miss
          puts "STATS[#{name}]: #{hits} HITS, #{miss} MISS"
        else
          puts "NO STATS[#{name}]"
        end
      end

    else
      define_method(name) do |*args|
        @memoized_method_calls ||= {}
        @memoized_method_calls[name] ||= {}
        cache = @memoized_method_calls[name]

        if cache.key?(args)
          cache[args]
        else
          cache[args] = send(orig_name, *args)
        end
      end
    end
  end

end
