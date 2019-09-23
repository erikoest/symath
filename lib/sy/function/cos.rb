require 'sy/function/trig'

module Sy
  class Function::Cos < Function::Trig
    def reduce()
      return reduce_sin_and_cos(1)
    end
  end
end
