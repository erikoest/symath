require 'sy/value'
require 'sy/type'

module Sy
  class Variable < Value
    attr_reader :name
    attr_reader :type
  
    def initialize(name, t)
      @name = name
      @type = t.to_t
    end

    def hash()
      return @name.to_s.hash
    end
    
    def ==(other)
      return false if self.class.name != other.class.name
      return false if @type != other.type
      return @name.to_s == other.name.to_s
    end

    def <=>(other)
      if self.class.name != other.class.name
        return super(other)
      end

      return @name.to_s <=> other.name.to_s
    end

    def scalar_factors()
      if @type.is_scalar?
        return [self].to_enum
      else
        return [].to_enum
      end
    end

    def vector_factors()
      if @type.is_vector? or @type.is_dform?
        return [self].to_enum
      else
        return [].to_enum
      end
    end

    def is_constant?(vars = nil)
      return false if vars.nil?
      return !(vars.member?(self))
    end

    # Returns true if variable is a differential form
    def is_diff?()
      return @type.is_dform?
    end

    # Returns variable which differential is based on
    # TODO: Check name collision with constant symbols (i, e, pi etc.)
    def undiff()
      return Sy::Variable.new(@name, 'real')
    end
    
    def to_diff()
      return Sy::Variable.new(@name, Sy::Type.new('dform'))
    end

    def variables()
      return [@name]
    end

    def replace(var, exp)
      if var.to_s == @name
        return exp.deep_clone
      else
        return self
      end
    end

    def to_s()
      if @type.is_dform?
        return :d.to_s + @name.to_s
      elsif @type.is_vector?
        return @name.to_s + ''''
      elsif @type.is_covector?
        return @name.to_s + '.'
      elsif @type.is_subtype?('tensor')
        return @name.to_s + '[' + @type.index_str + ']'
      else
        return @name.to_s
      end
    end

    def to_latex()
      if is_diff?
        return '\mathrm{d}' + undiff.to_latex
      else
        return @name.to_s
      end
    end
    
    alias eql? ==
  end
end

class String
  def to_m(type = 'real')
    begin
      return Sy::ConstantSymbol.new(self)
    rescue
      return Sy::Variable.new(self, type)
    end
  end
end

class Symbol
  def to_m(type = 'real')
    begin
      return Sy::ConstantSymbol.new(self)
    rescue
      return Sy::Variable.new(self, type)
    end
  end
end
