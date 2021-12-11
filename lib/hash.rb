Hash.module_eval do

  def with_default(value)
    self.default = value
    self
  end

  def remap
    each_with_object({}) do |(k, _), h|
      h[k] = yield(k)
    end
  end

end
