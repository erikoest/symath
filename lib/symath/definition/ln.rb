require 'symath/definition/function'

module SyMath
  class Definition::Ln < Definition::Function
    def initialize()
      super(:ln)

      @reductions_real = {
        1.to_m   => 0.to_m,
        :e.to_m  => 1.to_m,
        0.to_m   => -:oo.to_m,
        :oo.to_m => :oo.to_m,
      }

      @reductions_complex = {
        1.to_m      => 0.to_m,
        :e.to_m     => 1.to_m,
        -1.to_m     => :pi.to_m*:i,
        -:e.to_m    => 1.to_m + :pi.to_m*:i,
        :i.to_m     => :pi.to_m*:i/2,
        :e.to_m*:i  => 1.to_m + :pi.to_m*:i/2,
        -:i.to_m    => -:pi.to_m*:i/2,
        -:e.to_m*:i => 1.to_m - :pi.to_m*:i/2,
      }
    end

    def description()
      return 'ln(x) - natural logarithm'
    end

    def reduce_call(c)
      arg = c.args[0]

      if SyMath.setting(:complex_arithmetic)
        return super(c, @reductions_complex)
      else
        if arg.is_a?(SyMath::Minus)
          return :nan.to_m
        end

        return super(c, @reductions_real)
      end
    end
  end
end
