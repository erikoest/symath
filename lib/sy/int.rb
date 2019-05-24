require 'sy/value'
require 'sy/operator'

module Sy
  class Int < Operator
    attr_reader :var, :a, :b

    def initialize(arg, var = nil, a = nil, b = nil)
      super('int', [arg])

      if !var.nil?
        if !var.is_a?(Sy::Variable)
          raise "Expected variable for var, got " + var.class.name
        end

        if !var.is_diff?
          raise "Expected var to be a differential, got " + var.to_s
        end
      end

      if (!a.nil? and b.nil?) or (a.nil? and !b.nil?)
        raise "A cannot be defined without b and vica versa."
      end
      
      @var = var
      @a = a
      @b = b
    end

    def to_s()
      args = @args
      if !@var.nil?
        args.push @var
      end
      if !@a.nil?
        args.push @a, @b
      end
      
      return @name.to_s + '(' + args.map { |a| a.to_s }.join(',') + ')'
    end
  end
end
