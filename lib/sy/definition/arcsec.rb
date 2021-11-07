require 'sy/definition/function'

module Sy
  class Definition::Arcsec < Definition::Function
    def initialize()
      super(:arcsec)
    end

    def reduce_exp(e)
      return e
    end
  end
end
