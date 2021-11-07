require 'sy/definition/function'

module Sy
  class Definition::Arccsc < Definition::Function
    def initialize()
      super(:arccsc)
    end

    def reduce_exp(e)
      return e
    end
  end
end
