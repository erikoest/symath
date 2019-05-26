require 'sy/value'
require 'sy/operator'

module Sy
  class Diff < Operator
    def initialize(arg, *vars)
      super('diff', [arg])

      if vars.length == 0
        # Find first free variable in expression and expand d.
        vars = [arg.variables[0].to_m].to_set
      else
        vars.each do |v|
          if !v.is_a?(Sy::Variable)
            raise "Expected variable, got " + v.class.name
          end

          if v.is_diff?
            raise "Var is not allowed to be differential, got " + v.to_s
          end
        end
        vars = vars.to_set
      end

      @vars = vars
    end

    def act()
      return @@actions[:diff].act(*args, @vars)
    end
  end
end
