require 'sy/value'
require 'sy/operator'

module Sy
  class Hodge < Operator
    def initialize(arg)
      super('hodge', [arg])
    end

    def evaluate()
      return self
    end
    
    def to_latex()
      return '\star' + @args[0].to_latex
    end
  end
end
