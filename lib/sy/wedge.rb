require 'sy/function'

module Sy
  class Wedge < Product
    def initialize(arg1, arg2)
      super(arg1, arg2)
      @name = '^'
    end

    def type()
      if factor1.type.is_subtype?('tensor') and
        factor2.type.is_subtype?('tensor')
        return 'tensor'.to_t(indexes: factor1.type.indexes + factor2.type.indexes)
      else
        return factor1.type.sum(factor2.type)
      end
    end
    
    def to_s()
      return @args.map do |a|
        if a.is_sum_exp?
          '(' + a.to_s + ')'
        else
          a.to_s
        end
      end.join('^')
    end

    def to_latex()
      return @args.map { |a| a.to_latex }.join('\wedge')
    end
  end
end
