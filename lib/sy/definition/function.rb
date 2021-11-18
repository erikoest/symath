require 'sy/definition'

module Sy
  class Definition::Function < Definition::Operator
    def self.init_builtin()
      # Define the builtin functions
      Sy::Definition::Sqrt.new
      Sy::Definition::Sin.new
      Sy::Definition::Cos.new
      Sy::Definition::Tan.new
      Sy::Definition::Sec.new
      Sy::Definition::Csc.new
      Sy::Definition::Cot.new
      Sy::Definition::Arcsin.new
      Sy::Definition::Arccos.new
      Sy::Definition::Arctan.new
      Sy::Definition::Arcsec.new
      Sy::Definition::Arccsc.new
      Sy::Definition::Arccot.new
      Sy::Definition::Ln.new
      Sy::Definition::Exp.new
      Sy::Definition::Abs.new
      Sy::Definition::Fact.new

      # Functions defined by an expression
      expressions = [
        { :name => 'sinh',
          :exp  => '(e**x - e**-x)/2',
          :desc => 'hyperbolic sine',
        },
        { :name => 'cosh',
          :exp  => '(e**x + e**-x)/2',
          :desc => 'hyperbolic cosine',
        },
        { :name => 'tanh',
          :exp  => '(e**x - e**-x)/(e**x + e**-x)',
          :desc => 'hyperbolic tangent',
        },
        { :name => 'coth',
          :exp  => '(e**x + e**-x)/(e**x - e**-x)',
          :desc => 'hyperbolic cotangent',
        },
        { :name => 'sech',
          :exp  => '2/(e**x + e**-x)',
          :desc => 'hyperbolic secant',
        },
        { :name => 'csch',
          :exp  => '2/(e**x - e**-x)',
          :desc => 'hyperbolic cosecant',
        },
        { :name => 'arsinh',
          :exp  => 'ln(x + sqrt(x**2 + 1))',
          :desc => 'inverse hyperbolic sine',
        },
        { :name => 'arcosh',
          :exp  => 'ln(x + sqrt(x**2 - 1))',
          :desc => 'inverse hyperbolic cosine',
        },
        { :name => 'artanh',
          :exp  => 'ln((1 + x)/(1 - x))/2',
          :desc => 'inverse hyperbolic tangent',
        },
        { :name => 'arcoth',
          :exp  => 'ln((x + 1)/(x - 1))/2',
          :desc => 'inverse hyperbolic cotangent',
        },
        { :name => 'arsech',
          :exp  => 'ln((1/x + sqrt(x**-2 - 1)))',
          :desc => 'inverse hyperbolic secant',
        },
        { :name => 'arcsch',
          :exp  => 'ln((1/x + sqrt(x**-2 + 1)))',
          :desc => 'inverse hyperbolic cosecant',
        },
      ]

      expressions.each do |e|
        self.new(e[:name], args: [:x], exp: e[:exp],
                 description: "#{e[:name]}(x) - #{e[:desc]}")
      end
    end

    @@not_mentioned_funcs = {
      :+   => true,
      :-   => true,
      :*   => true,
      :/   => true,
      :**  => true,
      :'=' => true,
    }

    def self.functions()
      return self.definitions.select { |f|
        f.is_function? and !@@not_mentioned_funcs[f.name]
      }
    end

    @reductions = {}

    def reduce_call(c, reductions = nil)
      if reductions.nil?
        reductions = @reductions
      end

      if reductions.has_key?(c.args[0])
        return reductions[c.args[0]]
      end

      return c
    end

    # Check if expression is a constant fraction of pi and optionally
    # i (imaginary unit)
    def check_pi_fraction(e, im)
      gotpi = false
      gotim = !im
      c = 1
      dc = 1

      # Check that factors are only constant, divisor constant and pi.
      # Note: This code is similar to 'reduce_constant_factors'. Refactor?
      e.factors.each do |f|
        if f.is_divisor_factor?
          if f.base.is_number?
            dc *= f.base.value**f.exponent.argument.value
            next
          end
        end

        if f.is_negative_number?
          c *= - f.argument.value
          next
        end

        if f.is_number?
          c *= f.value
          next
        end

        if !gotpi and f == :pi
          gotpi = true
          next
        end

        if !gotim and f == :i
          gotim = true
          next
        end

        return nil
      end

      return nil if !gotpi and !gotim and c != 0

      return c, dc
    end
    
    def is_function?()
      return true
    end

    def latex_format()
      return "#{name}(%s)"
    end
  end
end

def fn(f, *args)
  return Sy::Operator.create(f, args.map { |a| a.nil? ? a : a.to_m })
end

def define_fn(name, args, exp = nil)
  if exp
    return Sy::Definition::Function.new(name, args: args, exp: exp)
  else
    return Sy::Definition::Function.new(name, args: args)
  end
end

require 'sy/definition/sin'
require 'sy/definition/cos'
require 'sy/definition/tan'
require 'sy/definition/sec'
require 'sy/definition/csc'
require 'sy/definition/cot'
require 'sy/definition/arcsin'
require 'sy/definition/arccos'
require 'sy/definition/arctan'
require 'sy/definition/arcsec'
require 'sy/definition/arccsc'
require 'sy/definition/arccot'
require 'sy/definition/ln'
require 'sy/definition/exp'
require 'sy/definition/abs'
require 'sy/definition/sqrt'
require 'sy/definition/fact'
require 'sy/definition/lmd'
