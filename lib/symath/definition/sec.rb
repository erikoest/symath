require 'symath/definition/trig'

module SyMath
  class Definition::Sec < Definition::Trig
    def initialize()
      super(:sec)
    end
    
    def description()
      return 'sec(x) - trigonometric secant'
    end

    def reduce_call(c)
      return reduce_sec_and_csc(c, 0)
    end
  end
end
