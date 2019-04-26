require 'sy/value'
require 'sy/operator'

module Sy
  class Function < Operator

    def is_commutative?()
      return false
    end
    
    def is_associative?()
      return false
    end

    def ==(other)
      # Check that name matches
      return false if (self.name != other.name)

      # Check that argument length matches
      return false if (self.args.length != other.args.length)
      
      # Check that arguments match in pairs
      if !self.is_commutative? then
        # Non commutative function. Just compare each argument
        # pairwise
        self.args.each_with_index do |a, i|
          if a != other.args[i] then
            return false
          end
        end

        return true
      end

      # Commutative function. We have find a match for each argument
      # in the other function, not regarding the order.
      equals = {}

      self.args.each_with_index do |s, is|
        other.args.each_with_index do |o, io|
          # This argument is already matched. Skip to the next
          if equals.has_key?(io) then
            next
          end

          if s.class != o.class then
            next
          end
          
          if s == o then
            equals[io] = is
            break
          end
        end
      end

      return equals.length == other.args.length
    end

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
