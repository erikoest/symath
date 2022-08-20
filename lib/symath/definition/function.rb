require 'symath/definition'

module SyMath
  class Definition::Function < Definition::Operator
    def self.init_builtin()
      # Define the builtin functions
      SyMath::Definition::Sqrt.new
      SyMath::Definition::Sin.new
      SyMath::Definition::Cos.new
      SyMath::Definition::Tan.new
      SyMath::Definition::Sec.new
      SyMath::Definition::Csc.new
      SyMath::Definition::Cot.new
      SyMath::Definition::Arcsin.new
      SyMath::Definition::Arccos.new
      SyMath::Definition::Arctan.new
      SyMath::Definition::Arcsec.new
      SyMath::Definition::Arccsc.new
      SyMath::Definition::Arccot.new
      SyMath::Definition::Ln.new
      SyMath::Definition::Exp.new
      SyMath::Definition::Abs.new
      SyMath::Definition::Fact.new

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
  return SyMath::Operator.create(f, args.map { |a| a.nil? ? a : a.to_m })
end

def define_fn(name, args, exp = nil)
  if exp
    return SyMath::Definition::Function.new(name, args: args, exp: exp)
  else
    return SyMath::Definition::Function.new(name, args: args)
  end
end

require 'symath/definition/sin'
require 'symath/definition/cos'
require 'symath/definition/tan'
require 'symath/definition/sec'
require 'symath/definition/csc'
require 'symath/definition/cot'
require 'symath/definition/arcsin'
require 'symath/definition/arccos'
require 'symath/definition/arctan'
require 'symath/definition/arcsec'
require 'symath/definition/arccsc'
require 'symath/definition/arccot'
require 'symath/definition/ln'
require 'symath/definition/exp'
require 'symath/definition/abs'
require 'symath/definition/sqrt'
require 'symath/definition/fact'
require 'symath/definition/lmd'
