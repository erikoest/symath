require 'symath/definition/function'

module SyMath
  class Definition::Arccsc < Definition::Function
    def initialize()
      super(:arccsc)

      @reductions = {
        -2.to_m           => -:pi/6,
        -fn(:sqrt, 2)     => -:pi/4,
        -2*fn(:sqrt, 3)/3 => -:pi/3,
        -1.to_m           => -:pi/2,
        1.to_m            => :pi/2,
        2*fn(:sqrt, 3)/3  => :pi/3,
        fn(:sqrt, 2)      => :pi/4,
        2.to_m            => :pi/6,
      }
    end

    def description()
      return 'arccsc(x) - inverse trigonometric cosecant'
    end
  end
end
