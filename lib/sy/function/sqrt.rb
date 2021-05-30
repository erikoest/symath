require 'sy/function/sqrt'
# require 'math'

module Sy
  class Function::Sqrt < Function
    def reduce
      i = 1.to_m
      arg = self.args[0]

      # Real: sqrt(-n) = NaN
      # Complex: sqrt(-n) = i*sqrt(n)
      if arg.is_negative?
        if Sy.setting(:complex_arithmetic)
          i = :i.to_m
          arg = -arg
        else
          return :NaN.to_m
        end
      end

      if arg.is_number?
        # sqrt(n*n) = n
        # sqrt(-n*n) = i*n
        if (Math.sqrt(arg.value) % 1).zero?
          return i*Math.sqrt(arg.value).to_i
        end
      elsif arg.is_a?(Sy::Power)
        # sqrt(n**(2*a)) = n^a
        # sqrt(-n**(2*a)) = i*n**a

        # Find coefficient of exponent
        c = 1
        arg.exponent.factors.each do |ef|
          if ef.is_number?
            c *= ef.value
          end
        end
        
        if c.even?
          return i*arg.base**(arg.exponent/2)
        end
      end

      if i != 1
        return i*fn(:sqrt, arg)
      else
        return self
      end
    end

    def to_latex
      return '\sqrt{'.to_s + args[0].to_latex + '}'.to_s
    end
  end
end
