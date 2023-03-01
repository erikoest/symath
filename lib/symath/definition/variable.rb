require 'symath/value'
require 'symath/type'
require 'symath/vectorspace'

module SyMath
  class Definition::Variable < Definition
    attr_reader :vector_space
    attr_reader :exact

    def initialize(name, t = 'real', v: nil, exact: false)
      t = t.to_t
      if t.is_subtype?('tensor')
        if !v.is_a?(SyMath::VectorSpace)
          @vector_space = SyMath.get_vector_space(v)
        else
          @vector_space = v
        end

        @exact = exact
      end

      super(name, define_symbol: false, type: t)
    end

    def is_exact?
      return @exact
    end

    def description()
      return "#{name} - free variable"
    end

    def call(*args)
      return SyMath::Operator.create(self, args.map { |a| a.nil? ? a : a.to_m })
    end

    def ==(other)
      return false if self.class.name != other.class.name
      return false if @type != other.type
      return @name == other.name
    end

    def <=>(other)
      if self.class.name != other.class.name
        return super(other)
      end

      if type.name != other.type.name
        return type.name <=> other.type.name
      end
      # Order basis vectors and basis forms by basis order
      if type.is_subtype?('vector') or type.is_subtype?('form')
        # First, order by vector space
        if self.vector_space.name != other.vector_space.name
          return self.vector_space.name <=> other.vector_space.name
        end

        # Order basis vectors by basis order
        bv1 = self.vector_space.basis_order(self)
        bv2 = other.vector_space.basis_order(other)

        if bv1 and bv2
          return bv1 <=> bv2
        end

        if !bv1 and bv2
          # Order basis vectors higher than other vectors
          return 1
        end

        if bv1 and !bv2
          # Order basis vectors higher than other vectors
          return -1
        end
      end

      return @name.to_s <=> other.name.to_s
    end

    def is_constant?(vars = nil)
      return false if vars.nil?
      return !(vars.member?(self))
    end

    def is_unitary?
      if type.is_subtype?('tensor') and vector_space.normalized?
        return true
      end

      return false
    end

    # Returns true if variable is a differential form.
    # By convention, we treat all forms beginning with the character 'd' as
    # differential forms.
    def is_d?()
      return (@type.is_oneform? and @name != 'd' and @name[0] == 'd')
    end

    # Returns variable which a differential form is based on
    def undiff()
      n = "#{@name}"
      if n[0] == 'd'
        n = n[1..-1]
      end

      n.to_sym.to_m(:real)
    end

    # Create a differential form based on a variable
    def to_d()
      # d^2 = 0
      return 0.to_m if is_exact?

      return "d#{@name}".to_sym.to_m(:form, exact: true)
    end

    def variables()
      return [self]
    end

    def replace(map)
      if is_d?
        u = undiff
        if map.key?(u)
          return op(:d, map[u].deep_clone)
        else
          return self
        end
      end

      if map.key?(self)
        return map[self].deep_clone
      else
        return self
      end
    end

    def product_reductions()
      if self.vector_space
        return vector_space.product_reductions_by_variable(self)
      else
        return
      end
    end

    def reduce_product_modulo_sign(o)
      if (self.type.is_oneform? and o.type.is_vector?)
        # <a|a> = 1
        if self.vector_space == o.vector_space and
          self.vector_space.normalized? and self.name == o.name
          return 1.to_m, 1, true
        end
      end

      return super(o)
    end

    def to_matrix()
      if vector_space
        return vector_space.variable_to_matrix(self)
      else
        return self
      end
    end

    def to_latex()
      if @type.is_vector?
        if vector_space.normalized? and SyMath.setting(:braket_syntax)
          return "\\ket{#{qubit_name}}"
        else
          return "\\vec{#{@name}}"
        end
      elsif @type.is_form?
        # What is the best way to denote a oneform without using indexes?
        if vector_space.normalized? and SyMath.setting(:braket_syntax)
          return "\\bra{#{qubit_name}}"
        else
          return "#{@name}"
        end
      elsif @type.is_subtype?('tensor')
        return "#{@name}[#{@type.index_str}]"
      else
        return "#{@name}"
      end
    end

    alias eql? ==
  end
end

class Symbol
  def to_m(type = nil, v: nil, exact: false)
    ret = nil

    begin
      # Look up the already defined symbol
      # (we might want to check that it is a constant or variable)
      ret = SyMath::Definition.get(self, type)
    rescue
      # Not defined. Define it now.
      if type.nil?
        type = 'real'
      end

      ret = SyMath::Definition::Variable.new(self, type, v: v, exact: exact)
    end

    if !ret.allow_standalone?
      raise "Symbol #{self} cannot be used without arguments."
    end

    return ret
  end
end
