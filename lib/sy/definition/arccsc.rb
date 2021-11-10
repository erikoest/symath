require 'sy/definition/function'

module Sy
  class Definition::Arccsc < Definition::Function
    def initialize()
      super(:arccsc)
    end

    def reduce_call(c)
      return c
    end
  end
end
