require 'sy/definition/function'

module Sy
  class Definition::Arccos < Definition::Function
    def initialize()
      super(:arccos)
    end

    def reduce_call(c)
      return c
    end
  end
end
