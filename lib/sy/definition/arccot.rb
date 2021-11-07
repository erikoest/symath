require 'sy/definition/function'

module Sy
  class Definition::Arccot < Definition::Function
    def initialize()
      super(:arccot)
    end

    def reduce_exp(e)
      return e
    end
  end
end
