require 'sy/definition/trig'

module Sy
  class Definition::Csc < Definition::Trig
    def initialize()
      super(:csc)
    end
    
    def reduce_call(c)
      return reduce_sec_and_csc(c, 0)
    end
  end
end
