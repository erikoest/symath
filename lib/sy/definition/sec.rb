require 'sy/definition/trig'

module Sy
  class Definition::Sec < Definition::Trig
    def initialize()
      super(:sec)
    end
    
    def reduce_call(c)
      return reduce_sec_and_csc(c, 0)
    end
  end
end