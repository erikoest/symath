require 'symath/definition/function'

module SyMath
  class Definition::Arccos < Definition::Function
    def initialize()
      super(:arccos)

      @reductions = {
        -1.to_m         => :pi,
        -fn(:sqrt, 3)/2 => 5*:pi/6,
        -fn(:sqrt, 2)/2 => 3*:pi/4,
        -1.to_m/2       => 2*:pi/3,
        0.to_m          => :pi/2,
        1.to_m/2        => :pi/3,
        fn(:sqrt, 2)/2  => :pi/4,
        fn(:sqrt, 3)/2  => :pi/6,
        1.to_m          => 0.to_m,
      }
    end

    def description()
      return 'arccos(x) - inverse trigonometric cosine'
    end
  end
end
