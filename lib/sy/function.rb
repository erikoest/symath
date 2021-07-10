require 'sy/value'
require 'sy/operator'
require 'set'

module Sy
  class Function < Operator
    def has_action?()
      return !Sy.get_function(self.name.to_sym).nil?
    end
    
    def evaluate()
      if !has_action?
        return self
      end

      f = Sy.get_function(self.name.to_sym)
      if !f.nil?
        d = f[:definition]
        res = f[:expression].deep_clone
        if res.args.length == self.args.length
          map = {}
          d.args.each_with_index do |a, i|
            map[a] = self.args[i]
          end
          res.replace(map)
          return res
        end
      end

      return self
    end

    def to_latex()
      return @name.to_s + '(' + @args.map { |a| a.to_latex }.join(',') + ')'
    end

    @@function_symbols = [
      :+, :-, :*, :/, :**, :^, :%, :!
    ].to_set
    
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
#      :sinh   => 'Sy::Function::Sinh',
#      :cosh   => 'Sy::Function::Cosh',
#      :tanh   => 'Sy::Function::Tanh',
#      :sech   => 'Sy::Function::Sech',
#      :csch   => 'Sy::Function::Csch',
#      :coth   => 'Sy::Function::Coth',
#      :arsinh => 'Sy::Function::Arsinh',
#      :arcosh => 'Sy::Function::Arcosh',
#      :artanh => 'Sy::Function::Artanh',
#      :arsech => 'Sy::Function::Arsech',
#      :arcsch => 'Sy::Function::Arcsch',
#      :arcoth => 'Sy::Function::Arcoth',
      :ln     => 'Sy::Function::Ln',
      :exp    => 'Sy::Function::Exp',
      :abs    => 'Sy::Function::Abs',
      :fact   => 'Sy::Function::Fact',
      :sqrt   => 'Sy::Function::Sqrt',
    }

    def self.builtin(name, args)
      name = name.to_sym
      if !@@builtin_functions.key?(name)
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
