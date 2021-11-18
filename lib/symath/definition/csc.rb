require 'symath/definition/trig'

module SyMath
  class Definition::Csc < Definition::Trig
    def initialize()
      super(:csc)
    end
    
    def description()
      return 'csc(x) - trigonometric cosecant'
    end

    def reduce_call(c)
      return reduce_sec_and_csc(c, 0)
    end
  end
end
