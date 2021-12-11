Range.class_eval do

  def abs
    self.begin <= self.end ? self : Range.new(self.end, self.begin)
  end

  def intersection(range)
    raise TypeError, "no implicit conversion of #{range.class} into Range" unless range.is_a?(Range)

    min1, min2 = self.imin, range.imin
    max1, max2 = self.imax, range.imax

    if max1.nil? || max2.nil?
      self.begin ... self.begin
    else
      (min1 > min2 ? min1 : min2) .. (max1 < max2 ? max1 : max2)
    end
  end

  alias :& :intersection

  protected

  def imin
    case self.begin
    when Float::INFINITY, NilClass
      -Float::INFINITY
    else
      min
    end
  end

  def imax
    case self.end
    when Float::INFINITY, NilClass
      Float::INFINITY
    else
      max
    end
  end

end
