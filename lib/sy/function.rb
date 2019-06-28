require 'sy/value'
require 'sy/operator'
require 'set'

module Sy
  class Function < Operator
    @@function_symbols = [
      :+, :-, :*, :/, :**, :^, :%, :!
    ].to_set
    
    @@builtin_functions = [
      :abs, :sqrt,
      :exp, :ln,
      :sin, :cos, :tan, :sec, :csc, :cot,
      :arcsin, :arccos, :arctan, :arcsec, :arccsc, :arccot,
      :sinh, :cosh, :tanh, :sech, :csch, :coth,
      :arsinh, :arcosh, :artanh, :arsech, :arcsch, :arcoth,
    ].to_set

    def self.builtin_functions()
      return @@builtin_functions
    end
  end
end

def fn(name, *args)
  return Sy::Function.new(name, args.map { |a| a.to_m })
end
