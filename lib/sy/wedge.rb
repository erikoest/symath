require 'sy/function'

module Sy
  class Wedge < Product
    def initialize(arg1, arg2)
      super(arg1, arg2)
      @name = '^'
    end

    def abs_factors_exp()
      if factor1.is_a?(Sy::Number) and factor2.is_a?(Sy::Number)
        return 1.to_m
      end

      if factor1.is_a?(Sy::Number)
        return factor2
      end

      if factor2.is_a?(Sy::Number)
        return factor1
      end

      return factor1.abs_factors_exp.wedge(factor2.abs_factors_exp)
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
