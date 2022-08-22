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

    def reduce_product_modulo_sign(o)
      if o.is_number?
        return (self.value*o.value).to_m, 1, true
      end

      return 0, 1, false
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
