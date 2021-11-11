require 'sy/definition/function'

module Sy
  class Definition::Arccsc < Definition::Function
    def initialize()
      super(:arccsc)
    end

    def reduce_call(c)
      r = {
        -2.to_m           => -:pi/6,
        -fn(:sqrt, 2)     => -:pi/4,
        -2*fn(:sqrt, 3)/3 => -:pi/3,
        -1.to_m           => -:pi/2,
        1.to_m            => :pi/2,
        2*fn(:sqrt, 3)/3  => :pi/3,
        fn(:sqrt, 2)      => :pi/4,
        2.to_m            => :pi/6,
      }

      if r.has_key?(c.args[0])
        return r[c.args[0]]
      end

      return c
    end
  end
end
