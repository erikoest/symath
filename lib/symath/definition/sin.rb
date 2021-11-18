require 'symath/definition/trig'

module SyMath
  class Definition::Sin < Definition::Trig
    def initialize()
      super(:sin)
    end

    def description()
      return 'sin(x) - trigonometric sine'
    end

    def reduce_call(c)
      return reduce_sin_and_cos(c, 0)
    end
  end
end
