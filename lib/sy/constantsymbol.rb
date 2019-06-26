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

    def type()
      if @name == 'e' or @name == 'pi' or @name == 'phi'
        return 'real'.to_t
      elsif @name == :i
        return 'imaginary'.to_t
      else
        return 'unknown'.to_t
      end
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
