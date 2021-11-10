require 'sy/definition/trig'

module Sy
  class Definition::Cot < Definition::Trig
    def initialize()
      super(:cot)
    end
    
    def reduce_call(c)
      return reduce_tan_and_cot(c, 1, -1)
    end
  end
end
