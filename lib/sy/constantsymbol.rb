require 'sy/constant'
require 'set'

module Sy
  class ConstantSymbol < Constant
    attr_reader :value

    SYMBOLS = ['pi', 'e', 'i', 'phi', 'sq2'].to_set

    def initialize(name, value)
      raise 'Not a known symbol: ' + name.to_s if !SYMBOLS.member?(name.to_s)
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
