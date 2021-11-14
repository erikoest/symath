require 'sy/value'
require 'sy/definition/function'

module Sy
  class Definition::Lmd < Definition::Function
    def initialize(exp, *vars)
      super('', args: vars, exp: exp, define_symbol: false)
    end

    def description()
      return "{self.to_s} - Lambda function of expression #{exp}"
    end

    def compose_with_simplify(exp, vars)
      vars.each do |v|
        if !v.is_a?(Sy::Definition::Variable)
          raise "Expected variable, got #{v.class.name}"
        end

        if v.is_d?
          raise "Var is not allowed to br differential, got #{v}"
        end
      end

      # Simplify lmd(f(*args), *args) to f(*args)
      if !exp.is_a?(Sy::Operator)
        return
      end

      if !exp.definition.is_function?
        return
      end

      if exp.arity != vars.length
        return
      end

      exp.args.each do |a|
        if !a.is_a?(Sy::Definition::Variable)
          return
        end

        if a.is_d?
          return
        end
      end

      return exp
    end

    # For a lambda function, the call returns a function with a reference
    # to our own lambda function definition.
    def call(*args)
      args = args.map { |a| a.nil? ? a : a.to_m }
      return Sy::Operator.new(self, args)
    end

    def reduce()
      # FIXME: Reduce if lmd is just a wrapper around a function.
      return self
    end
    
    def to_s(args = nil)
      if !args
        args = @args
      end

      if args.length > 0
        arglist = args.map { |a| a.to_s }.join(',')
      else
        arglist = "..."
      end

      return "(#{exp}).(#{arglist})"
    end

    def latex_format()
      return "(#{exp}).(%s)"
    end
  end
end

def lmd(exp, args)
  # Create a lamda (nameless) function.
  return Sy::Definition::Lmd.new(exp, args)
end
