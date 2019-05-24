require 'sy/value'

module Sy
  class Variable < Value
    attr_reader :name
    attr_reader :value
  
    def initialize(name, value = nil)
      @name = name
      @value = value
    end

    def hash()
      return @name.to_s.hash
    end
    
    def ==(other)
      return false if self.class.name != other.class.name
      return @name.to_s == other.name.to_s
    end

    def <=>(other)
      if self.class.name != other.class.name
        return super(other)
      end

      return @name.to_s <=> other.name.to_s
    end

    def is_constant?(vars = nil)
      return false if vars.nil?
      return !(vars.member?(self))
    end

    # Returns true if variable is a differential
    # As for now, all variables beginning with d are differentials
    def is_diff?()
      return @name[0] == 'd'
    end

    # Returns variable which differential is based on
    # Todo: check that return value really is a variable (dpi, de, di, etc.)
    def undiff()
      return @name[1..-1].to_m
    end
    
    def variables()
      return [@name]
    end
    
    def to_s()
      if @value.nil?
        return @name.to_s
      else
        return @name.to_s + ' = ' + @value
      end
    end

    alias eql? ==
  end
end

class String
  def to_m()
    begin
      return Sy::ConstantSymbol.new(self)
    rescue
      return Sy::Variable.new(self)
    end
  end
end

class Symbol
  def to_m()
    begin
      return Sy::ConstantSymbol.new(self)
    rescue
      return Sy::Variable.new(self)
    end
  end
end
