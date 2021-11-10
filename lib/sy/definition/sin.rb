require 'sy/definition/trig'

module Sy
  class Definition::Sin < Definition::Trig
    def initialize()
      super(:sin)
    end

    def reduce_call(c)
      return reduce_sin_and_cos(c, 0)
    end
  end
end
