require 'sy/definition/function'

module Sy
  class Definition::Arcsin < Definition::Function
    def initialize()
      super(:arcsin)
    end

    def reduce_call(c)
      # -1         -> -pi/2
      # -sqrt(3)/2 -> -pi/3
      # -sqrt(2)/2 -> -pi/4
      # -1/2       -> -pi/6
      # 0          -> 0
      # 1/2        -> pi/6
      # sqrt(2)/2  -> pi/4
      # sqrt(3)/2  -> pi/3
      # 1          -> pi/2
      
      return c
    end
  end
end
