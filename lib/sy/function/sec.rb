require 'sy/function/trig'

module Sy
  class Function::Sec < Function::Trig
    def reduce()
      return reduce_sec_and_csc(0)
    end
  end
end
