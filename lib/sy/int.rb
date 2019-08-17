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

    def evaluate()
      if a.nil?
        return @@actions[:int].act(*args, var) + :C.to_m
      else
        int = @@actions[:int].act(*args, var)
        return op(:bounds, int, var.undiff, a, b)
      end
    end
    
    def to_s()
      ret = @name.to_s + '(' + @args.map { |a| a.to_s }.join(',')
      if !@var.nil?
        ret += ',' + @var.to_s
      end

      if !@a.nil?
        ret += ',' + @a.to_s + ',' + @b.to_s
      end

      ret += ')'
      return ret
    end

    def to_latex()
      if @args[0].is_sum_exp?
        exp = '\left(' + @args[0].to_latex + '\right)'
      else
        exp = @args[0].to_latex
      end

      if @a.nil?
        return '\int ' + exp + '\,' + @var.to_latex
      else
        return '\int_{' + @a.to_latex + '}^{' + @b.to_latex + '} ' +
               exp + '\, ' + @var.to_latex
      end
    end
  end
end
