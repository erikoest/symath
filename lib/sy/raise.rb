require 'sy/value'
require 'sy/operator'

module Sy
  class Raise < Operator
    def initialize(arg)
      super('raise', [arg])
    end

    def evaluate()
      @@actions[:raise].calc_basic_vectors
      return @@actions[:raise].act(*args)
    end
    
    def to_string()
      return '#(' + @args[0] + ')'
    end
    
    def to_latex()
      return @args[0].to_latex + '\sharp'
    end
  end
end
