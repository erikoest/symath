require 'sy/value'
require 'sy/operator'

module Sy
  class Laplacian < Operator
    def initialize(arg)
      super('laplacian', [arg])
    end

    # The laplacian is defined as *d*dF
    def get_definition()
      return 'laplacian(F) = hodge(xd(hodge(xd(F))))'.to_mexp
    end

    def to_latex()
      return '\nabla^2 ' + @args[0].to_latex
    end
  end
end
