require 'sy/value'
require 'sy/operator'

module Sy
  class D < Operator
    def self.compose_with_simplify(arg, *vars)
      if arg.is_a?(Sy::Variable) and
        arg.type.is_scalar? and
        vars.length == 0
        return arg.to_d
      end

      return self.new(arg, *vars)
    end

    def initialize(arg, *vars)
      super('d', [arg])

      if vars.length == 0
        # Find first free variable in expression and expand d.
        vars = [arg.variables[0].to_m]
      else
        vars.each do |v|
          if !v.is_a?(Sy::Variable)
            raise "Expected variable, got " + v.class.name
          end

          if v.is_d?
            raise "Var is not allowed to be differential, got " + v.to_s
          end
        end
      end

      @vars = vars.to_set
    end

    def evaluate()
      return args[0].d(@vars)
    end

    def to_latex()
      return '\mathrm{d}(' + @args[0].to_latex + ')'
    end
  end
end
