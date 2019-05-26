require 'sy/value'
require 'sy/operator'
require 'set'

module Sy
  class Function < Operator
    @@builtin_functions = [
      'exp', 'ln',
      'sin', 'cos', 'tan',
      'sec', 'csc', 'cot'
    ].to_set;

    def self.builtin_functions()
      return @@builtin_functions
    end
  end
end

def fn(name, *args)
  return Sy::Function.new(name, args.map { |a| Sy.value(a) })
end
