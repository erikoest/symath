require 'sy/value'
require 'sy/operator'

module Sy
  class Equation < Operator
    def initialize(arg1, arg2)
      super('=', [arg1, arg2])
    end

    def +(other)
      if other.is_a?(Sy::Equation)
        return eq(self.args[0] + other.args[0], self.args[1] + other.args[1])
      else
        return eq(self.args[0] + other, self.args[1] + other)
      end
    end

    def -(other)
      if other.is_a?(Sy::Equation)
        return eq(self.args[0] - other.args[0], self.args[1] - other.args[1])
      else
        return eq(self.args[0] - other, self.args[1] - other)
      end
    end

    def -@()
      return eq(-self.args[0], -self.args[1])
    end

    def *(other)
      if other.is_a?(Sy::Equation)
        raise 'Cannot multiply two equations'
      else
        return eq(self.args[0] * other, self.args[1] * other)
      end
    end

    def /(other)
      if other.is_a?(Sy::Equation)
        raise 'Cannot divide by equation'
      else
        return eq(self.args[0] / other, self.args[1] / other)
      end
    end

    def **(other)
      if other.is_a?(Sy::Equation)
        raise 'Cannot use equation as exponent'
      else
        return eq(self.args[0]**other, self.args[1]**other)
      end
    end

    def to_s()
      return "#{@args[0]} = #{@args[1]}"
    end

    def to_latex()
      return "#{@args[0]} = #{@args[1]}"
    end
  end
end

# Convenience method
def eq(a, b)
  return Sy::Equation.new(a, b)
end
