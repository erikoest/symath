require 'sy/definition/function'

module Sy
  class Definition::Arcsin < Definition::Function
    def initialize()
      super(:arcsin)

      @reductions = {
        -1.to_m         => -:pi/2,
        -fn(:sqrt, 3)/2 => -:pi/3,
        -fn(:sqrt, 2)/2 => -:pi/4,
        -1.to_m/2       => -:pi/6,
        0.to_m          => 0.to_m,
        1.to_m/2        => :pi/6,
        fn(:sqrt, 2)/2  => :pi/4,
        fn(:sqrt, 3)/2  => :pi/3,
        1.to_m          => :pi/2,
      }
    end

    def description()
      return 'arcsin(x) - inverse trigonometric sine'
    end
  end
end
