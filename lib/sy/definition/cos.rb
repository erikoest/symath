require 'sy/definition/trig'

module Sy
  class Definition::Cos < Definition::Trig
    def initialize()
      super(:cos)
    end
    
    def reduce_exp(e)
      return reduce_sin_and_cos(e, 1)
    end
  end
end
