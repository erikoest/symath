require 'sy/function/trig'

module Sy
  class Function::Cot < Function::Trig
    def reduce()
      return reduce_tan_and_cot(1, -1)
    end
  end
end
