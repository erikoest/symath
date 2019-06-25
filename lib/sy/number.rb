require 'sy/constant'

module Sy
  class Number < Constant
    def value()
      return self.name.to_i
    end

    # Scalar factor is empty because the numeric value is counted as
    # coefficient
    def scalar_factors()
      return []
    end

    def coefficient()
      return self.value
    end

    def type()
      return type('natural')
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
