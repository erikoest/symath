# coding: utf-8
require 'symath/product'

module SyMath
  class Outer < Product
    def initialize(arg1, arg2)
      super(arg1, arg2)
      @name = '×'
    end

    def type()
      if factor1.type.is_subtype?('tensor') and
         factor2.type.is_subtype?('tensor')
        # Outer product of two tensor-like object. Determine index signature
        # and subtype.
        indexes = factor1.type.indexes + factor2.type.indexes
        if (indexes - ['u']).empty?
          type = 'vector'
        elsif (indexes - ['l']).empty?
          type = 'covector'
        else
          type = 'tensor'
        end

        return type.to_t(indexes: indexes)
      else
        return factor1.type.product(factor2.type)
      end
    end

    def is_prod_exp?()
      return false
    end

    def factors()
      # Override from product. Don't enumerate factors
      return [self].to_enum
    end

    def calc_mx
      # We represent the outer product of matrices as the kroenecker product.
      f1 = factor1.calc_mx
      f2 = factor2.calc_mx

      if f1.type.is_matrix? and f2.type.is_matrix?
        return f1.kroenecker(f2)
      else
        return f1.outer(f2)
      end
    end

    def mul_symbol
      return ' × '
    end

    def mul_symbol_ltx
      return '\otimes'
    end
  end
end
