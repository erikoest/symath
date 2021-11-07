require 'sy/definition/trig'

module Sy
  class Definition::Sin < Definition::Trig
    def initialize()
      super(:sin)
    end

    def reduce_exp(e)
      return reduce_sin_and_cos(e, 0)
    end
  end
end
