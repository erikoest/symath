require 'sy/definition/function'

module Sy
  class Definition::Exp < Definition::Function
    def initialize()
      super(:exp)
    end

    def reduce_call(call)
      arg = call.args[0]
      
      if arg.is_nan?
        return :nan.to_m
      end

      if arg == 0
        return 1.to_m
     elsif arg == 1
        return :e.to_m
      end

      if arg.is_finite? == false
        if Sy.setting(:complex_arithmetic)
          return :nan.to_m
        else
          if arg.is_positive? == true
            return :oo.to_m
          else
            return 0.to_m
          end
        end
      end

      if Sy.setting(:complex_arithmetic)
        ret = 1.to_m
      
        arg.terms.each do |t|
          if t.is_a?(Sy::Minus)
            t = t.args[0]
            minus = true
          else
            minus = false
          end

          if t.class.method_defined?('definition') and t.definition.is_a?(Sy::Definition::Ln)
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
                return call
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
              return call
            end
          end

          ret = minus ? ret/t2 : ret*t2
        end

        return ret
      else
        ret = 1.to_m

        call.args[0].terms.each do |t|
          if t.is_a?(Sy::Minus)
            t = t.args[0]
            minus = true
          else
            minus = false
          end

          # exp(ln(c)) = c for positive c
          if t.class.method_defined?('definition') and t.definition.is_a?(Sy::Definition::Ln)
            if t.args[0].is_number?
              ret = minus ? ret/t.args[0] : ret*t.args[0]
              next
            end
          end

          # Cannot reduce
          return call
        end

        return ret
      end
    end
  end
end
