require 'sy/definition/function'

module Sy
  class Definition::Arccot < Definition::Function
    def initialize()
      super(:arccot)

      @reductions = {
        -fn(:sqrt, 3)   => 5*:pi/6,
        -1.to_m         => 3*:pi/4,
        -fn(:sqrt, 3)/3 => 2*:pi/3,
        0.to_m          => :pi/2,
        fn(:sqrt, 3)/3  => :pi/3,
        1.to_m          => :pi/4,
        fn(:sqrt, 3)    => :pi/6,
      }
    end

    def description()
      return 'arccot(x) - inverse trigonometric cotangent'
    end
  end
end
