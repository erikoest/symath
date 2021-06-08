require 'sy/value'
require 'sy/operator'

module Sy
  class Flat < Operator
    def initialize(arg)
      super('flat', [arg])
    end

    def evaluate()
      # Must normalize input, operation depends on factorized vectors
      return args[0].normalize.flat
    end

    def to_string()
      return 'b(' + @args[0].to_s + ')'
    end
    
    def to_latex()
      return @args[0].to_latex + '^\flat'
    end
  end
end
