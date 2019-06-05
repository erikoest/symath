require 'sy/constant'
require 'set'

module Sy
  class ConstantSymbol < Constant
    attr_reader :value

    @@symbols = ['pi', 'e', 'i', 'phi'].to_set

    def self.builtin_constants()
      return @@symbols
    end
    
    def initialize(name, value = nil)
      raise 'Not a known symbol: ' + name.to_s if !@@symbols.member?(name.to_s)
      super(name)
      @value = value
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

    def to_latex()
      if @name == 'pi'
        return '\pi'
      elsif @name == 'phi'
        return '\varphi'
      elsif @name == 'e'
        return '\mathrm{e}'
      else
        return @name
      end
    end
  end
end
