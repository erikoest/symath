require 'sy/definition/trig'

module Sy
  class Definition::Cos < Definition::Trig
    def initialize()
      super(:cos)
    end
    
    def description()
      return "cos(x) - trigonometric cosine"
    end

    def reduce_call(c)
      return reduce_sin_and_cos(c, 1)
    end
  end
end
