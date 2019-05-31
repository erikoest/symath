require 'sy/operation'
require 'sy/function'

module Sy
  class Operation::TrigReduction < Operation

    def initialize()
      sqrt3 = fn(:sqrt, 3)
      sqrt2 = fn(:sqrt, 2)
      
      @sin_div6 = [ 0.to_m,   1.to_m/2,     sqrt3/2,
                    1.to_m,   sqrt3/2,      1.to_m/2,
                    0.to_m,  -(1.to_m/2),  -(sqrt3/2),
                   -1.to_m,  -(sqrt3/2),   -(1.to_m/2)]

      @sin_div4 = [ 0.to_m,   sqrt2/2,
                    1.to_m,   sqrt2/2,
                    0.to_m,  -(sqrt2/2),
                   -1.to_m,  -(sqrt2/2)]

      @sec_div6 = [ 1.to_m,    2.to_m*sqrt3/3,     2.to_m,
                    nil,      -2.to_m,            -(2.to_m*sqrt3/2),
                   -1.to_m,   -(2.to_m*sqrt3/3),  -2.to_m,
                    nil,       2.to_m,             2.to_m*sqrt3/3]

      @sec_div4 = [ 1.to_m,   sqrt2/2,
                    nil,     -(sqrt2/2),
                   -1.to_m,  -(sqrt2/2),
                    nil,      sqrt2/2]
      
      @cot_div6 = [nil,      sqrt3,       sqrt3/3,
                   0.to_m,  -(sqrt3/3),  -sqrt3]
      
      @tan_div6 = [0.to_m,   sqrt3/3,   sqrt3,
                   nil,     -sqrt3,    -(sqrt3/3)]

      @tan_div4 = [0.to_m,   1.to_m,
                   nil,     -1.to_m]
    end

    def description
      return 'Reduce trigonometric functions'
    end

    def result_is_normal?
      return true
    end

    def act(exp)
      res = exp.deep_clone

      # Recurse down operator arguments
      res = act_subexpressions(res)
      res = exp if res.nil?

      if res.is_a?(Sy::Function)
        res = case res.name.to_s
              when 'sin'
                do_sin(res)
              when 'cos'
                do_cos(res)
              when 'tan'
                do_tan(res)
              when 'cot'
                do_cot(res)
              when 'sec'
                do_sec(res)
              when 'csc'
                do_csc(res)
              else
                nil
              end
      end

      return res.nil? ? exp : res
    end

    def check_factors(exp)
      pi = :pi.to_m

      exp.args[0].abs_factors.each do |f|
        return false if (pi.nil?)
        return false if f != pi
        pi = nil
      end
        
      exp.args[0].div_factors.each do |e|
        return false
      end

      return true
    end

    def reduce_sin(exp, off)
      return exp unless check_factors(exp)

      c = exp.args[0].coefficient
      dc = exp.args[0].div_coefficient

      # Divisor is divisible by 6
      if 6 % dc == 0
        return @sin_div6[(off*3 + c*6/dc) % 12]
      end
      
      # Divisor is divisible by 4
      if 4 % dc == 0
        return @sin_div4[(off*2 + c*4/dc) % 8]
      end

      return exp
    end
    
    def do_sin(exp)
      return reduce_sin(exp, 0)
    end

    def do_cos(exp)
      return reduce_sin(exp, 1)
    end

    def reduce_tan(exp, off, sign)
      return exp unless check_factors(exp)

      c = exp.args[0].coefficient
      dc = exp.args[0].div_coefficient

      # Divisor is divisible by 6
      if 6 % dc == 0
        return @tan_div6[(off*3 + sign*c*6/dc) % 6]
      end
      
      # Divisor is divisible by 4
      if 4 % dc == 0
        return @tan_div4[(off*2 + sign*c*4/dc) % 4]
      end

      return exp
    end

    def do_tan(exp)
      return reduce_tan(exp, 0, 1)
    end
    
    def do_cot(exp)
      return reduce_tan(exp, 1, -1)
    end

    def reduce_sec(exp, off)
      return exp unless check_factors(exp)

      c = exp.args[0].coefficient
      dc = exp.args[0].div_coefficient

      # Divisor is divisible by 6
      if 6 % dc == 0
        return @sec_div6[(off*3 + c*6/dc) % 12]
      end
      
      # Divisor is divisible by 4
      if 4 % dc == 0
        return @sec_div4[(off*2 + c*4/dc) % 8]
      end

      return exp
    end
    
    def do_sec(exp)
      return reduce_sec(exp, 0)
    end

    def do_csc(exp)
      return reduce_sec(exp, 0)
    end
  end
end
