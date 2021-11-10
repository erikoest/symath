require 'sy/value'
require 'sy/definition/operator'

module Sy
  class Definition::Flat < Definition::Operator
    def initialize()
      super(:flat)
    end

    def evaluate_call(c)
      # Must normalize input, operation depends on factorized vectors
      return c.args[0].normalize.flat
    end

    def to_s(args = nil)
      if !args
        args = @args
      end

      return "b(#{args[0]})"
    end
    
    def latex_format()
      return '%s^\flat'
    end
  end
end
