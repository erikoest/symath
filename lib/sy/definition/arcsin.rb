require 'sy/definition/function'

module Sy
  class Definition::Arcsin < Definition::Function
    def initialize()
      super(:arcsin)
    end

    def reduce_exp(e)
      # -1         -> -pi/2
      # -sqrt(3)/2 -> -pi/3
      # -sqrt(2)/2 -> -pi/4
      # -1/2       -> -pi/6
      # 0          -> 0
      # 1/2        -> pi/6
      # sqrt(2)/2  -> pi/4
      # sqrt(3)/2  -> pi/3
      # 1          -> pi/2
      
      return e
    end
  end
end
