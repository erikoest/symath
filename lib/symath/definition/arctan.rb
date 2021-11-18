require 'symath/definition/function'

module SyMath
  class Definition::Arctan < Definition::Function
    def initialize()
      super(:arctan)

      @reductions = {
        -fn(:sqrt, 3)   => -:pi/3,
        -1.to_m         => -:pi/4,
        -fn(:sqrt, 3)/3 => -:pi/6,
        0.to_m          => 0.to_m,
        fn(:sqrt, 3)/3  => :pi/6,
        1.to_m          => :pi/4,
        fn(:sqrt, 3)    => :pi/3,
      }
    end

    def description()
      return 'arctan(x) - inverse trigonometric tangent'
    end
  end
end
