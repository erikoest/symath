require 'sy/constant'

module Sy
  class ConstantSymbol < Constant
    attr_reader :value

    def initialize(name, value)
      super(name)
      @value = value
    end

    def ==(other)
      return false if other.class != self.class

      return other.value == self.value
    end

    def match(other, varmap)
      if self == other then
        return varmap
      end

      return
    end

    def replace(varmap)
      return self
    end
  end
end
