Enumerable.class_eval do

  def tsort
    each do |obj|
      unless obj.respond_to?(:id) && obj.respond_to?(:depends_on)
        raise ArgumentError, "Can not tsort on #{obj.inspect} unless responds to #id and #depends_on"
      end
    end

    lookup = index_by(&:id)
    each_node = ->(&b) { lookup.each_key(&b) }
    each_child = ->(id, &b) { lookup.fetch(id).depends_on(&b) }
    lookup.values_at(*TSort.tsort(each_node, each_child))
  end

end
