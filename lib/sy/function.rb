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

    def has_action?()
      return !Sy.get_function(self.name.to_sym).nil?
    end
    
    def evaluate()
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
  end
end

def fn(name, *args)
  return Sy::Function.new(name, args.map { |a| a.to_m })
end
