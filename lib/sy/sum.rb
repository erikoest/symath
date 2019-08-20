require 'sy/function'

module Sy
  class Sum < Function
    def initialize(arg1, arg2)
      super('+', [arg1, arg2])
    end

    def term1()
      return @args[0]
    end

    def term2()
      return @args[1]
    end
    
    def is_sum_exp?()
      return true
    end

    def is_scalar?()
      return (term1.is_scalar? and term2.is_scalar?)
    end
    
    # Return all terms in the sum
    def terms()
      return Enumerator.new do |s|
        term1.terms.each { |s1| s << s1 }
        term2.terms.each { |s2| s << s2 }
      end
    end

    def type()
      return term1.type.sum(term2.type)
    end
    
    def to_s()
      if Sy.setting(:expl_parentheses)
        return '('.to_s + term1.to_s + ' + ' + term2.to_s + ')'.to_s
      else
        if term2.is_a?(Sy::Minus)
          return term1.to_s + ' ' + term2.to_s
        else
          return term1.to_s + ' + ' + term2.to_s
        end
      end
    end

    def to_latex()
      if term2.is_a?(Sy::Minus)
        return term1.to_latex + ' ' + term2.to_latex
      else
        return term1.to_latex + ' + ' + term2.to_latex
      end
    end
  end
end
