require 'matrix'

Vector.module_eval do

  include Adjacent

  alias :deconstruct :to_a

  protected

  def _single_adjacent(dir, **opts)
    Vector[*super]
  end

end
