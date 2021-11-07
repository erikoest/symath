require 'sy/definition/trig'

module Sy
  class Definition::Tan < Definition::Trig
    def initialize()
      super(:tan)
    end
    
    def reduce_exp(e)
      return reduce_tan_and_cot(e, 0, 1)
    end
  end
end
