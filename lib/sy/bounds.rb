require 'sy/value'
require 'sy/operator'

module Sy
  class Bounds < Operator
    attr_reader :var, :a, :b

    def initialize(arg, var, a, b)
      super('bounds', [arg])

      if !var.is_a?(Sy::Variable)
        raise "Expected variable for var, got " + var.class.name
      end

      if !var.type.is_scalar?
        raise "Expected var to be a scalar, got " + var.to_s
      end

      @var = var
      @a = a
      @b = b
    end

    def evaluate()
      return args[0].integral_bounds(var, a, b)
    end

    def to_s()
      return '[' + @args[0].to_s + '](' + @a.to_s + ',' + @b.to_s + ')'
    end

    def to_latex()
      return '\left[' + @args[0].to_latex + '\right]^{' + @b.to_latex + '}_{' +
             @a.to_latex + '}'
    end
  end
end


