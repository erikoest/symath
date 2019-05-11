require 'sy/constant'

module Sy
  class Number < Constant
    def value()
      return self.name.to_i
    end

    def abs_factors()
      return []
    end

    def abs_factors_exp()
      return 1.to_m
    end
    
    def coefficient()
      return self.value
    end
  end
end

class Integer
  def to_m()
    if self < 0
      return -Sy::Number.new(-self)
    else
      return Sy::Number.new(self)
    end
  end
end
