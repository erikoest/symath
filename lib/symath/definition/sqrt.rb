require 'symath/definition/function'

module SyMath
  class Definition::Sqrt < Definition::Function
    def initialize()
      super(:sqrt)
    end

    def description()
      return 'sqrt(x) - square root'
    end

    def reduce_call(call)
      arg = call.args[0]
      i = 1.to_m

      # Real: sqrt(-n) = NaN
      # Complex: sqrt(-n) = i*sqrt(n)
      if arg.is_a?(SyMath::Minus)
        if SyMath.setting(:complex_arithmetic)
          i = :i.to_m
          arg = -arg
        else
          return :nan.to_m
        end
      end

      if arg.is_number?
        # sqrt(n*n) = n
        # sqrt(-n*n) = i*n
        if (Math.sqrt(arg.value) % 1).zero?
          return i*Math.sqrt(arg.value).to_i
        end
      elsif arg.is_a?(SyMath::Power)
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
        return call
      end
    end

    def reduce_power_call(call, e)
      arg = call.args[0]

      if e.is_a?(SyMath::Minus)
        sign = -1
        e = -e
      else
        sign = 1
      end

      if e.is_number?
        if e.value.even?
          e = (sign*e.value/2).to_m
          return arg**e, 1, true
        end
      end

      return call, 1, false
    end

    def to_latex(args = nil)
      return '\sqrt{'.to_s + args[0].to_latex + '}'.to_s
    end
  end
end
