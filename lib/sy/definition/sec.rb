require 'sy/definition/trig'

module Sy
  class Definition::Sec < Definition::Trig
    def initialize()
      super(:sec)
    end
    
    def reduce_exp(e)
      return reduce_sec_and_csc(e, 0)
    end
  end
end
