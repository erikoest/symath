require 'symath/value'
require 'symath/operator'

module SyMath
  class Equation < Operator
    def initialize(arg1, arg2)
      super('=', [arg1, arg2])
    end

    def +(other)
      if other.is_a?(SyMath::Equation)
        return eq(self.args[0] + other.args[0], self.args[1] + other.args[1])
      else
        return eq(self.args[0] + other, self.args[1] + other)
      end
    end

    def -(other)
      if other.is_a?(SyMath::Equation)
        return eq(self.args[0] - other.args[0], self.args[1] - other.args[1])
      else
        return eq(self.args[0] - other, self.args[1] - other)
      end
    end

    def -@()
      return eq(-self.args[0], -self.args[1])
    end

    def *(other)
      if other.is_a?(SyMath::Equation)
        raise 'Cannot multiply two equations'
      else
        return eq(self.args[0] * other, self.args[1] * other)
      end
    end

    def /(other)
      if other.is_a?(SyMath::Equation)
        raise 'Cannot divide by equation'
      else
        return eq(self.args[0] / other, self.args[1] / other)
      end
    end

    def **(other)
      if other.is_a?(SyMath::Equation)
        raise 'Cannot use equation as exponent'
      else
        return eq(self.args[0]**other, self.args[1]**other)
      end
    end

    def to_s()
      return "#{@args[0]} = #{@args[1]}"
    end

    def to_latex()
      return @args[0].to_latex + ' = ' + @args[1].to_latex
    end
  end
end

# Convenience method
def eq(a, b)
  return SyMath::Equation.new(a, b)
end
