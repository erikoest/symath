require 'sy/value'
require 'sy/operator'

module Sy
  class Grad < Operator
    def initialize(arg)
      super('grad', [arg])
    end

    # Grad is defined as (dF)#
    def get_definition()
      return {
        :definition => op(:grad, :x),
        :expression => op(:sharp, op(:xd, :x)),
      }
    end

    def to_latex()
      return '\nabla ' + @args[0].to_latex
    end
  end
end
