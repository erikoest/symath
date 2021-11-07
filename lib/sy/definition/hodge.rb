require 'sy/value'
require 'sy/definition/operator'

module Sy
  class Definition::Hodge < Definition::Operator
    def initialize()
      super(:hodge)
    end

    def evaluate(e)
      # Must normalize input, operation depends on factorized vectors
      return e.args[0].normalize.hodge
    end

    def latex_format()
      return '\star %s'
    end
  end
end
