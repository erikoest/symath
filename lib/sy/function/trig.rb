require 'sy/function'

module Sy
  class Function::Trig < Function
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
        
        :cot_div6 => [nil,      sqrt3,       sqrt3/3,
                      0.to_m,  -(sqrt3/3),  -sqrt3],
      
        :tan_div6 => [0.to_m,   sqrt3/3,   sqrt3,
                      nil,     -sqrt3,    -(sqrt3/3)],
      
        :tan_div4 => [0.to_m,   1.to_m,
                      nil,     -1.to_m],
      }
    end

    def reduce_check_factors()
      gotpi = false
      c = 1
      dc = 1

      # Check that factors are only constant, divisor constant and pi.
      # Note: This code is similar to 'reduce_constant_factors'. Refactor?
      args[0].factors.each do |f|
        if f.is_divisor_factor?
          if f.base.is_number?
            dc *= f.base.value**f.exponent.argument.value
            next
          end
        end

        if f.is_negative_number?
          c *= - f.argument.value
          next
        end

        if f.is_number?
          c *= f.value
          next
        end

        return nil if gotpi
        return nil if f != :pi
        gotpi = true
      end

      return nil if !gotpi and c != 0

      return c, dc
    end

    def reduce_sin_and_cos(off)
      c, dc = reduce_check_factors
      return self if c.nil?

      # Divisor is divisible by 6
      if 6 % dc == 0
        return @@trig_reductions[:sin_div6][(off*3 + c*6/dc) % 12]
      end
    
      # Divisor is divisible by 4
      if 4 % dc == 0
        return @@trig_reductions[:sin_div4][(off*2 + c*4/dc) % 8]
      end

      return self
    end

    def reduce_tan_and_cot(off, sign)
      c, dc = reduce_check_factors
      return self if c.nil?

      # Divisor is divisible by 6
      if 6 % dc == 0
        return @@trig_reductions[:tan_div6][(off*3 + sign*c*6/dc) % 6]
      end
      
      # Divisor is divisible by 4
      if 4 % dc == 0
        return @@trig_reductions[:tan_div4][(off*2 + sign*c*4/dc) % 4]
      end

      return self
    end

    def reduce_sec_and_csc(off)
      c, dc = reduce_check_factors
      return self if c.nil?
    
      # Divisor is divisible by 6
      if 6 % dc == 0
        return @@trig_reductions[:sec_div6][(off*3 + c*6/dc) % 12]
      end
    
      # Divisor is divisible by 4
      if 4 % dc == 0
        return @@trig_reductions[:sec_div4][(off*2 + c*4/dc) % 8]
      end
    
      return self
    end
  end
end
