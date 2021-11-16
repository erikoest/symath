require 'sy/value'
require 'sy/definition/operator'

module Sy
  class Definition::Int < Definition::Operator
    def initialize()
      super(:int)
    end

    def description()
      return 'int(f, a, b) - integral of f [from a to b]'
    end
    
    def validate_args(e)
      a = e.args[1]
      b = e.args[2]

      if (!a.nil? and b.nil?) or (a.nil? and !b.nil?)
        raise "A cannot be defined without b and vica versa."
      end
    end

    def get_variable(exp)
      if exp.is_a?(Sy::Operator) and
        exp.definition.is_function?
        v = exp.definition.args[0]
      else
        v = (exp.variables)[0].to_m
      end

      return v.to_d
    end

    def evaluate_call(c)
      exp = c.args[0]
      var = get_variable(exp)
      a = c.args[1]
      b = c.args[2]

      exp = exp.recurse('evaluate')

      if a.nil?
        ret = exp.normalize.anti_derivative(var)
        return ret.nil? ? nil : ret + :C.to_m
      else
        int = exp.normalize.anti_derivative(var)
        return op(:bounds, int, var.undiff, a, b)
      end
    end

    def to_latex(args)
      if !args
        args = @args
      end
      
      if args[0].is_sum_exp?
        exp = "\\left(#{args[0].to_latex}\\right)"
      else
        exp = args[0].to_latex
      end

      var = get_variable(args[0])
      a = args[1]
      b = args[2]

      if a.nil?
        return "\\int #{exp}\\,#{var.to_latex}"
      else
        return "\\int_{#{a.to_latex}}^{#{b.to_latex}} #{exp}\\,#{var.to_latex}"
      end
    end
  end
end
