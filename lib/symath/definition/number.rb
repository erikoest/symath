require 'symath/definition'

module SyMath
  class Definition::Number < Definition
    def initialize(name)
      super(name.to_s, define_symbol: false)
    end

    def description()
      return "#{name} - natural number"
    end

    def value()
      return self.name.to_s.to_i
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

    def reduce_power_modulo_sign(e)
      # Powers of 1 reduces to 1
      if self == 1 and e.is_finite?
        return self, 1, true
      end

      # Power of 0 reduces to 0
      if self == 0 and e.is_finite? and e != 0
        return self, 1, true
      end

      if e.is_number?
        return (value ** e.value).to_m, 1, true
      end

      if e.is_negative_number? and e.argument.value > 1
        return (value ** e.argument.value).to_m.power(-1), 1, true
      end

      return 0.to_m, 1, false
    end

    def reduce_product_modulo_sign(o)
      if o.is_number?
        return (self.value*o.value).to_m, 1, true
      end

      return 0.to_m, 1, false
    end

    def type()
      return :natural.to_t
    end
  end
end

class Integer
  def to_m()
    if self < 0
      return SyMath::Definition::Number.new(-self).neg
    else
      return SyMath::Definition::Number.new(self)
    end
  end
end
