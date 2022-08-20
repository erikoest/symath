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

    def mul_symbol
      return ' × '
    end

    def mul_symbol_ltx
      return '\otimes'
    end
  end
end
