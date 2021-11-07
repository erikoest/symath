require 'sy/definition/trig'

module Sy
  class Definition::Cot < Definition::Trig
    def initialize()
      super(:cot)
    end
    
    def reduce_exp(e)
      return reduce_tan_and_cot(e, 1, -1)
    end
  end
end
