require 'sy/definition/trig'

module Sy
  class Definition::Tan < Definition::Trig
    def initialize()
      super(:tan)
    end
    
    def reduce_call(c)
      return reduce_tan_and_cot(c, 0, 1)
    end
  end
end
