require 'sy/value'
require 'sy/operator'

module Sy
  class Function < Operator
    def match(other, varmap)
      return if (self.class != other.class)
      return if (self.name != other.name)
      return if (self.args.length != other.args.length)

      self.args.each_with_index do |a, i|
        varmap = a.match(expr.args[i], varmap)

        return if !varmap
      end

      return varmap
    end

    def replace(varmap)
      @args = self.args.map { |a| a.replace(varmap) }
      return self
    end
  end
end

def fn(name, *args)
  return Sy::Function.new(name, args.map { |a| Sy.value(a) })
end
