require 'sy/definition/trig'

module Sy
  class Definition::Csc < Definition::Trig
    def initialize()
      super(:csc)
    end
    
    def reduce_exp(e)
      return reduce_sec_and_csc(e, 0)
    end
  end
end
