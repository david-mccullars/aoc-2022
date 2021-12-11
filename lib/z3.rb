Z3::IntExpr.class_eval do

  def abs
    (self < 0).ite(-self, self)
  end

end
