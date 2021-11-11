require 'sy/definition/function'

module Sy
  class Definition::Arctan < Definition::Function
    def initialize()
      super(:arctan)
    end

    def reduce_call(c)
      r = {
        -fn(:sqrt, 3)   => -:pi/3,
        -1.to_m         => -:pi/4,
        -fn(:sqrt, 3)/3 => -:pi/6,
        0.to_m          => 0.to_m,
        fn(:sqrt, 3)/3  => :pi/6,
        1.to_m          => :pi/4,
        fn(:sqrt, 3)    => :pi/3,
      }

      if r.has_key?(c.args[0])
        return r[c.args[0]]
      end

      return c
    end
  end
end
