require 'symath/definition/trig'

module SyMath
  class Definition::Tan < Definition::Trig
    def initialize()
      super(:tan)
    end
    
    def description()
      return 'tan(x) - trigonometric tangent'
    end

    def reduce_call(c)
      return reduce_tan_and_cot(c, 0, 1)
    end
  end
end
