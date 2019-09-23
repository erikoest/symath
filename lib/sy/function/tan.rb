require 'sy/function/trig'

module Sy
  class Function::Tan < Function::Trig
    def reduce()
      return reduce_tan_and_cot(0, 1)
    end
  end
end
