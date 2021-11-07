require 'sy/definition/function'

module Sy
  class Definition::Arccos < Definition::Function
    def initialize()
      super(:arccos)
    end

    def reduce_exp(e)
      return e
    end
  end
end
