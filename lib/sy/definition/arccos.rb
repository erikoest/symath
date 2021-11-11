require 'sy/definition/function'

module Sy
  class Definition::Arccos < Definition::Function
    def initialize()
      super(:arccos)
    end

    def reduce_call(c)
      r = {
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

      if r.has_key?(c.args[0])
        return r[c.args[0]]
      end

      return c
    end
  end
end
