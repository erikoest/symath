require 'sy/value'
require 'sy/definition/operator'

module Sy
  class Definition::Sharp < Definition::Operator
    def initialize()
      super(:sharp)
    end

    def evaluate_call(c)
      # Must normalize input, operation depends on factorized vectors
      return c.args[0].normalize.sharp
    end
    
    def to_s(args = nil)
      if !args
        args = @args
      end

      return "\#(#{args[0]})"
    end

    def latex_format()
      return '%s^\sharp'
    end
  end
end
