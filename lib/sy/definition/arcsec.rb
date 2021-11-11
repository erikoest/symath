require 'sy/definition/function'

module Sy
  class Definition::Arcsec < Definition::Function
    def initialize()
      super(:arcsec)
    end

    def reduce_call(c)
      r = {
        -2.to_m           => 2*:pi/3,
        -fn(:sqrt, 2)     => 3*:pi/4,
        -2*fn(:sqrt, 3)/3 => 5*:pi/6,
        -1.to_m           => :pi,
        1.to_m            => 0.to_m,
        2*fn(:sqrt, 3)/3  => :pi/6,
        fn(:sqrt, 2)      => :pi/4,
        2.to_m            => :pi/3
      }

      if r.has_key?(c.args[0])
        return r[c.args[0]]
      end

      return c
    end
  end
end
