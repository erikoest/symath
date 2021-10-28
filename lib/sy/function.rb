require 'sy/value'
require 'sy/operator'
require 'set'

module Sy
  class Function < Operator
    def get_definition()
      return Sy.get_function(self.name)
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

    def to_latex()
      return @name.to_s + '(' + @args.map { |a| a.to_latex }.join(',') + ')'
    end

    @@builtin_functions = {
      :sin    => 'Sy::Function::Sin',
      :cos    => 'Sy::Function::Cos',
      :tan    => 'Sy::Function::Tan',
      :sec    => 'Sy::Function::Sec',
      :csc    => 'Sy::Function::Csc',
      :cot    => 'Sy::Function::Cot',
#      :arcsin => 'Sy::Function::Arcsin',
#      :arccos => 'Sy::Function::Arccos',
#      :arctan => 'Sy::Function::Arctan',
#      :arcsec => 'Sy::Function::Arcsec',
#      :arccsc => 'Sy::Function::Arccsc',
#      :arccot => 'Sy::Function::Arccot',
      :ln     => 'Sy::Function::Ln',
      :exp    => 'Sy::Function::Exp',
      :abs    => 'Sy::Function::Abs',
      :fact   => 'Sy::Function::Fact',
      :sqrt   => 'Sy::Function::Sqrt',
    }

    @@builtin_function_definitions = [
      'sinh(x) = (e**x - e**-x)/2',
      'cosh(x) = (e**x + e**-x)/2',
      'tanh(x) = (e**x - e**-x)/(e**x + e**-x)',
      'coth(x) = (e**x + e**-x)/(e**x - e**-x)',
      'sech(x) = 2/(e**x + e**-x)',
      'csch(x) = 2/(e**x - e**-x)',
      'arcsinh(x) = ln(x + sqrt(x**2 + 1))',
      'arccosh(x) = ln(x + sqrt(x**2 - 1))',
      'arctanh(x) = ln((1 + x)/(1 - x))/2',
      'arccoth(x) = ln((x + 1)/(x - 1))/2',
      'arcsech(x) = ln((1/x + sqrt(x**-2 - 1)))',
      'arccsch(x) = ln((1/x + sqrt(x**-2 + 1)))',
    ]

    # Define operator symbol
    def self.define_symbol(name)
      if !Sy::Symbols.private_method_defined?(name) and
        !Sy::Symbols.method_defined?(name) and
        !@@skip_method_def[name.to_sym]

        clazz = self
        Sy::Symbols.define_method :"#{name}" do |*args|
          return clazz.new(name, args.map { |a| a.to_m })
        end
      end
    end

    def self.init_builtin_functions()
      @@builtin_functions.keys.each do |f|
        clazz = Object.const_get(@@builtin_functions[f])
        clazz.define_symbol(f)
      end

      @@builtin_function_definitions.each do |d|
        Sy.define_function(d.to_mexp)
      end
    end

    def self.is_builtin?(name)
      return @@builtin_functions.key?(name)
    end

    def self.builtin(name, args)
      name = name.to_sym
      if !self.is_builtin?(name)
        return
      end

      clazz = Object.const_get(@@builtin_functions[name])
      return clazz.new(name, args.map { |a| a.to_m })
    end
  end
end

def fn(name, *args)
  fn = Sy::Function.builtin(name, args)
  if !fn.nil?
    return fn
  end

  # Not a built-in function. Create a custom one.
  return Sy::Function.new(name, args.map { |a| a.to_m })
end

require 'sy/function/sin'
require 'sy/function/cos'
require 'sy/function/tan'
require 'sy/function/sec'
require 'sy/function/csc'
require 'sy/function/cot'
require 'sy/function/abs'
require 'sy/function/ln'
require 'sy/function/exp'
require 'sy/function/sqrt'
require 'sy/function/fact'
