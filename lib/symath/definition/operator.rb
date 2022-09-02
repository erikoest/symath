require 'symath/definition'

module SyMath
  class Definition::Operator < Definition
    attr_reader :args
    attr_reader :exp

    def self.init_builtin()
      SyMath::Definition::D.new
      SyMath::Definition::Xd.new
      SyMath::Definition::Int.new
      SyMath::Definition::Bounds.new
      SyMath::Definition::Sharp.new
      SyMath::Definition::Flat.new
      SyMath::Definition::Hodge.new
      SyMath::Definition::Grad.new
      SyMath::Definition::Curl.new
      SyMath::Definition::Div.new
      SyMath::Definition::Laplacian.new
      SyMath::Definition::CoDiff.new

      # Hermitian adjoint
      SyMath::Definition::Herm.new

      # QLogic gate operators
      SyMath::Definition::QX.new
      SyMath::Definition::QY.new
      SyMath::Definition::QZ.new
      SyMath::Definition::QH.new
      SyMath::Definition::QS.new
      SyMath::Definition::QCNOT.new

      expressions = [
        { :name => 'laplace',
          :exp  => 'lmd(int(f.(t)*e**(-s*t),d(t),0,oo),s)',
          :desc => 'laplace transform',
        },
        { :name => 'fourier',
          :exp  => 'lmd(int(f.(x)*e**(-2*pi*i*x*w),d(x),-oo,oo),w)',
          :desc => 'fourier transform',
        },
        { :name => 'invfourier',
          :exp  => 'lmd(int(f.(w)*e**(2*pi*i*x*w),d(w),-oo,oo),x)',
          :desc => 'inverse fourier transform',
        },
      ]

      expressions.each do |e|
        self.new(e[:name], args: [:f], exp: e[:exp],
                 description: "#{e[:name]}(f) - #{e[:desc]}")
      end

      e = op(:d, lmd(:f, :t))/op(:d, :t)
      self.new('dpart', args: [:f, :t], exp: e,
               description: 'dpart - partial derivative')
    end

    def self.operators()
      return self.definitions.select do |d|
        d.is_operator? and !d.is_function?
      end
    end

    def initialize(name, args: [], exp: nil, define_symbol: true,
                   type: 'operator', description: nil)
      if exp and !exp.is_a?(SyMath::Value)
        exp = exp.to_m
      end

      @reductions = {}
      @args = args.map { |a| a.to_m }
      @exp = exp

      super(name, define_symbol: define_symbol, description: description,
            type: type)
    end

    def compose_with_simplify(*args)
      return
    end

    def is_involutory?()
      return false
    end

    def is_unitary?()
      return false
    end

    def reduce_power_modulo_sign(exp)
      if is_involutory? and exp.is_number?
        if exp.value.even?
          return 1.to_m, 1.to_m, true
        else
          return self, 1.to_m, true
        end
      end

      return 0.to_m, 1, false
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

    alias eql? ==

    def <=>(other)
      s = super(other)
      return s if s != 0

      if arity != other.arity
        return arity <=> other.arity
      end

      (0...arity).to_a.each do |i|
        diff = args[i] <=> other.args[i]
        if diff != 0
          return diff
        end
      end

      return 0
    end

    # The call method, or the .() operator, returns an operator or function
    # object representing the operator or function being applied to a list of
    # arguments.
    def call(*args)
      return SyMath::Operator.create(name, args.map { |a| a.nil? ? a : a.to_m })
    end

    def is_operator?()
      return true
    end

    # Evaluate the operator in use
    def evaluate_call(c)
      if !exp
        # Operator has no expression, return it unchanged.
        return c
      end

      # Operator has expression. Exand it.
      res = exp.deep_clone
      if arity != c.arity
        raise "Cannot evaluate #{name} with #{c.arity} arguments. Expected #{arity}."
      end

      map = {}
      args.each_with_index do |a, i|
        map[a] = c.args[i]
      end
      res.replace(map)

      # Recursively evaluate the expanded formula.
      res = res.evaluate
      return res
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

      return self
    end

    def to_s(args = nil)
      if !args
        args = @args
      end

      if args.length > 0
        arglist = '(' + args.map { |a| a.to_s }.join(',') + ')'
      else
        if SyMath.setting(:braket_syntax)
          arglist = ''
        else
          arglist = '(...)'
        end
      end

      return "#{@name}#{arglist}"
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

    def dump(indent = 0)
      res = super(indent)
      i = ' '*indent
      if args
        arglist = args.map { |a| a.to_s }.join(',')
        res = "#{res}\n#{i}  args: #{arglist}"
      end
      if exp
        res = "#{res}\n#{i}  exp: #{exp}"
      end
    end
  end
end

def op(o, *args)
  return SyMath::Operator.create(o, args.map { |a| a.nil? ? a : a.to_m })
end

def define_op(name, args, exp = nil)
  if exp
    return SyMath::Definition::Operator.new(name, args: args, exp: exp)
  else
    return SyMath::Definition::Operator.new(name, args: args)
  end
end

require 'symath/definition/d'
require 'symath/definition/xd'
require 'symath/definition/int'
require 'symath/definition/bounds'
require 'symath/definition/sharp'
require 'symath/definition/flat'
require 'symath/definition/hodge'
require 'symath/definition/grad'
require 'symath/definition/curl'
require 'symath/definition/div'
require 'symath/definition/laplacian'
require 'symath/definition/codiff'
require 'symath/definition/herm'
require 'symath/definition/qlogicgate'
