require 'sy/constant'

module Sy
  class Number < Constant
    def value()
      return self.name.to_i
    end

    def coefficient()
      return self.value
    end
  end
end

class Integer
  def to_m()
    return Sy::Number.new(self)
  end
end
