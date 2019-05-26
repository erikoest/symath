require 'sy/value'
require 'sy/operator'

module Sy
  class Diff < Operator
    # TODO: Accept more than one variable
    def initialize(arg, var = nil)
      super('diff', [arg])

      if var.nil?
        # Find first free variable in expression and expand d.
        var = arg.variables[0].to_m
      else
        if !var.is_a?(Sy::Variable)
          raise "Expected variable for var, got " + var.class.name
        end

        if var.is_diff?
          raise "Var is a differential: " + var.to_s
        end
      end

      @var = var
    end

    def act()
      return @@actions[:diff].act(*args, @var)
    end
  end
end
