require 'sy/function/trig'

module Sy
  class Function::Sin < Function::Trig
    def reduce()
      return reduce_sin_and_cos(0)
    end
  end
end
