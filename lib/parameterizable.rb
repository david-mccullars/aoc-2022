module Parameterizable

  def [](**opts)
    names = opts.map do |a|
      a.map { _1.to_s.gsub(/(^|_)(.)/) { $2.upcase } }.join
    end

    names.reduce(self) do |scope, name|
      if scope.const_defined?(name)
        scope.const_get(name)
      else
        value = name == names[-1] ? parameterized_class(opts) : Module.new
        scope.const_set(name, value)
      end
    end
  end

  private

  def parameterized_class(opts)
    Class.new(self) do
      opts.each do |name, value|
        define_method(name) { value }
      end
    end.tap do |clazz|
      instance_variables.each do |iv|
        clazz.instance_variable_set(iv, instance_variable_get(iv))
      end
    end
  end

end
