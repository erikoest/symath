require 'sy/definition'

module Sy
  class Definition::Number < Definition
    def initialize(name)
      super(name.to_s, false)
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

    def type()
      return :natural.to_t
    end
  end
end

class Integer
  def to_m()
    if self < 0
      return Sy::Definition::Number.new(-self).neg
    else
      return Sy::Definition::Number.new(self)
    end
  end
end
