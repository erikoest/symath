require 'sy/constant'

module Sy
  class Number < Constant
    def value()
      return self.name.to_i
    end

    def has_action?()
      return false
    end

    def is_nan?()
      return false
    end
    
    def is_finite?()
      return true
    end

    def is_positive?()
      return value() > 0
    end

    def is_number?()
      return true
    end
    
    def is_zero?()
      return value() == 0
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
      return :natural.to_t
    end
  end
end

class Integer
  def to_m()
    if self < 0
      return Sy::Number.new(-self).neg
    else
      return Sy::Number.new(self)
    end
  end
end
