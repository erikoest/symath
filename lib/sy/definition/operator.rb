require 'sy/definition'

module Sy
  class Definition::Operator < Definition
    def self.init_builtin()
      Sy::Definition::D.new
      Sy::Definition::Xd.new
      Sy::Definition::Int.new
      Sy::Definition::Bounds.new
      Sy::Definition::Sharp.new
      Sy::Definition::Flat.new
      Sy::Definition::Hodge.new
      Sy::Definition::Grad.new
      Sy::Definition::Curl.new
      Sy::Definition::Div.new
      Sy::Definition::Laplacian.new
      Sy::Definition::CoDiff.new
    end

    def initialize(name, args: [], exp: nil)
      super(name)
      
      if exp and !exp.is_a?(Sy::Value)
        exp = exp.to_mexp
      end

      @args = args.map { |a| a.to_m }
      @exp = exp
    end

    def compose_with_simplify(*args)
      return
    end

    def validate_args(e)
      return
    end
    
    def arity()
      return @args.length
    end
    
    def ==(other)
      if !super(other)
        return false
      end

      o = other.to_m
      return false if self.args.length != o.args.length
      return false if self.exp != o.exp
      return false if self.args != o.args
      return true
    end

    # The call method, or the .() operator, returns an operator or function
    # object representing the operator or function being applied to a list of
    # arguments.
    def call(*args)
      return Sy::Operator.create(name, args.map { |a| a.nil? ? a : a.to_m })
    end

    def is_operator?()
      return true
    end

    def evaluate(e)
      if !exp
        # Operator has no expression, return it unchanged.
        return e
      end

      # Operator has expression. Exand it.
      res = exp.deep_clone
      if arity != e.arity
        raise "Cannot evaluate #{name} with #{e.arity} arguments. Expected #{arity}."
      end

      map = {}
      args.each_with_index do |a, i|
        map[a] = e.args[i]
      end
      res.replace(map)

      # Recursively evaluate the expanded formula.
      return res.recurse('evaluate')
      # return res
    end

    def replace(map)
      # FIXME: We probably need to filter out the local variables before
      # replacing
      if !exp.nil?
        @exp = exp.replace(map)
      end

      # Replace all arguments
      @args = @args.map do |a|
        a.replace(map)
      end
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

      return "#{@name}(#{arglist})"
    end

    def latex_format()
      return "\\operatorname{#{name}}(%s)"
    end
    
    def to_latex(args = nil)
      if !args
        args = @args
      end
      
      if args.length > 0
        arglist = args.map { |a| a.to_latex }.join(',')
      else
        arglist = "..."
      end

      return sprintf(latex_format, arglist)
    end
  end
end

def op(name, *args)
  s = Sy::Definition.get(name)
  if !s.is_operator? or s.is_function?
    raise "#{name} is not an operator"
  end

  return s.(*args)  
end

def define_op(name, args)
  return Sy::Definition::Operator.new(name, args: args)
end

require 'sy/definition/d'
require 'sy/definition/xd'
require 'sy/definition/int'
require 'sy/definition/bounds'
require 'sy/definition/sharp'
require 'sy/definition/flat'
require 'sy/definition/hodge'
require 'sy/definition/grad'
require 'sy/definition/curl'
require 'sy/definition/div'
require 'sy/definition/laplacian'
require 'sy/definition/codiff'
