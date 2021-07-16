require 'sy/value'
require 'sy/operator'

module Sy
  class Curl < Operator
    def initialize(arg)
      super('curl', [arg])
    end

    # Curl is defined as (*(d(Fb)))#
    def get_definition()
      if Sy.get_variable(:basis.to_m).row(0).length != 3
        raise 'Curl is only defined for 3 dimensions'
      end

      return 'curl(F) = #(hodge(xd(b(F))))'.to_mexp
    end

    def to_latex()
      return '\nabla\times ' + @args[0].to_latex
    end
  end
end
