require 'sy/definition/function'

module Sy
  class Definition::Arctan < Definition::Function
    def initialize()
      super(:arctan)
    end

    def reduce_call(c)
      return c
    end
  end
end
