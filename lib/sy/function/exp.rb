require 'sy/function'

module Sy
  class Function::Exp < Function
    def reduce()
      if args[0].is_nan?
        return :NaN.to_m
      end

      if args[0] == 0
        return 1.to_m
     elsif args[0] == 1
        return :e.to_m
      end

      if args[0].is_finite? == false
        if Sy.setting(:complex_arithmetic)
          return :NaN.to_m
        else
          if args[0].is_positive? == true
            return :oo.to_m
          else
            return 0.to_m
          end
        end
      end

      if Sy.setting(:complex_arithmetic)
        ret = 1.to_m
      
        args[0].terms.each do |t|
          if t.is_a?(Sy::Minus)
            t = t.argument
            minus = true
          else
            minus = false
          end

          if t.is_a?(Sy::Function::Ln)
            # exp(ln(c)) = c
            t2 = t.args[0]
          else
            # Euler's formula
            c, dc = check_pi_fraction(t, true)
            if !c.nil?
              if dc == 1
                c *= 2
              elsif dc != 2
                # Not reducible
                return self
              end

              case c % 4
              when 0
                t2 = 1
              when 1
                t2 = :i
              when 2
                t2 = -1
              when 3
                t2 = -:i
              end
            else
              # Cannot reduce
              return self
            end
          end

          ret = minus ? ret/t2 : ret*t2
        end

        return ret
      else
        ret = 1.to_m

        args[0].terms.each do |t|
          if t.is_a?(Sy::Minus)
            t = t.argument
            minus = true
          else
            minus = false
          end

          # exp(ln(c)) = c for positive c
          if t.is_a?(Sy::Function::Ln)
            if t.args[0].is_number?
              ret = minus ? ret/t.args[0] : ret*t.args[0]
              next
            end
          end

          # Cannot reduce
          return self
        end

        return ret
      end
    end
  end
end
