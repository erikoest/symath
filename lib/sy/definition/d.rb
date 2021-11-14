require 'sy/value'
require 'sy/definition/operator'

module Sy
  class Definition::D < Definition::Operator
    def initialize()
      super(:d)
    end

    def description()
      return 'd(f, x, y, ...) - differential of f with respect to variables x, y, ...'
    end
    
    def validate_args(e)
      # Arguments 1, 2, ... are supposed to be variables to differentiate
      # over.
      e.args[1..-1].each do |v|
        if !v.is_a?(Sy::Definition::Variable)
          raise "Expected variable, got #{v.class.name}"
        end

        if v.is_d?
          raise "Var is not allowed to be differential, got #{v}"
        end
      end
    end

    def compose_with_simplify(name, args)
      exp = args[0]
      vars = args[1..-1]

      if exp.is_a?(Sy::Definition::Variable) and
        exp.type.is_scalar? and
        vars.length == 0
        return exp.to_d
      end

      return
    end

    def evaluate_call(c)
      vars = c.args[1..-1]
      if vars.length == 0
        # Find first free variable in expression.
        vars = [(c.args[0].variables)[0].to_m]
      end

      return c.args[0].d(vars)
    end

    def latex_format()
      return '\mathrm{d}(%s)'
    end
  end
end
