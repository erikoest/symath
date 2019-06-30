require 'sy/value'
require 'sy/operator'

module Sy
  class Lower < Operator
    def initialize(arg)
      super('lower', [arg])
    end

    def evaluate()
      return self
    end

    def to_string()
      return 'b(' + @args[0] + ')'
    end
    
    def to_latex()
      return @args[0].to_latex + '\flat'
    end
  end
end
