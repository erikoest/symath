require 'sy/definition/function'

module Sy
  class Definition::Trig < Definition::Function
    @@trig_reductions = {}
  
    def self.initialize()
      sqrt3 = fn(:sqrt, 3)
      sqrt2 = fn(:sqrt, 2)

      @@trig_reductions = {
        :sin_div6 => [ 0.to_m,   1.to_m/2,     sqrt3/2,
                       1.to_m,   sqrt3/2,      1.to_m/2,
                       0.to_m,  -(1.to_m/2),  -(sqrt3/2),
                       -1.to_m,  -(sqrt3/2),   -(1.to_m/2)],
      
        :sin_div4 => [ 0.to_m,   sqrt2/2,
                       1.to_m,   sqrt2/2,
                       0.to_m,  -(sqrt2/2),
                       -1.to_m,  -(sqrt2/2)],
      
        :sec_div6 => [ 1.to_m,    2.to_m*sqrt3/3,     2.to_m,
                       nil,      -2.to_m,            -(2.to_m*sqrt3/2),
                       -1.to_m,   -(2.to_m*sqrt3/3),  -2.to_m,
                       nil,       2.to_m,             2.to_m*sqrt3/3],
      
        :sec_div4 => [ 1.to_m,   sqrt2/2,
                       nil,     -(sqrt2/2),
                       -1.to_m,  -(sqrt2/2),
                       nil,      sqrt2/2],
        
        :tan_div6 => [0.to_m,   sqrt3/3,   sqrt3,
                      nil,     -sqrt3,    -(sqrt3/3)],
      
        :tan_div4 => [0.to_m,   1.to_m,
                      nil,     -1.to_m],
      }
    end

    def reduce_sin_and_cos(f, off)
      c, dc = check_pi_fraction(f.args[0], false)
      return f if c.nil?

      # Divisor is divisible by 6
      if 6 % dc == 0
        return @@trig_reductions[:sin_div6][(off*3 + c*6/dc) % 12]
      end
    
      # Divisor is divisible by 4
      if 4 % dc == 0
        return @@trig_reductions[:sin_div4][(off*2 + c*4/dc) % 8]
      end

      return f
    end

    def reduce_tan_and_cot(f, off, sign)
      c, dc = check_pi_fraction(f.args[0], false)
      return f if c.nil?

      # Divisor is divisible by 6
      if 6 % dc == 0
        ret = @@trig_reductions[:tan_div6][(off*3 + sign*c*6/dc) % 6]
        return ret.nil? ? f : ret
      end

      # Divisor is divisible by 4
      if 4 % dc == 0
        ret = @@trig_reductions[:tan_div4][(off*2 + sign*c*4/dc) % 4]
        return ret.nil? ? f : ret
      end

      return f
    end

    def reduce_sec_and_csc(f, off)
      c, dc = check_pi_fraction(f.args[0], false)
      return f if c.nil?
    
      # Divisor is divisible by 6
      if 6 % dc == 0
        ret = @@trig_reductions[:sec_div6][(off*3 + c*6/dc) % 12]
        return ret.nil? ? f : ret
      end
    
      # Divisor is divisible by 4
      if 4 % dc == 0
        ret = @@trig_reductions[:sec_div4][(off*2 + c*4/dc) % 8]
        return ret.nil? ? f : ret
      end
    
      return f
    end
  end
end
