require 'sy/value'
require 'sy/operator'

module Sy
  class Hodge < Operator
    def initialize(arg)
      super('hodge', [arg])
    end

    def evaluate()
      # Must normalize input, operation depends on factorized vectors
      return args[0].normalize.hodge
    end
    
    def to_latex()
      return '\star ' + @args[0].to_latex
    end
  end
end
