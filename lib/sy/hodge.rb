require 'sy/value'
require 'sy/operator'

module Sy
  class Hodge < Operator
    def initialize(arg)
      super('hodge', [arg])
    end

    def evaluate()
      @@actions[:hodge].calculate_vector_pairs
      # Must normalize input, operation depends on factorized vectors
      return @@actions[:hodge].act(@@actions[:norm].act(*args))
    end
    
    def to_latex()
      return '\star ' + @args[0].to_latex
    end
  end
end
