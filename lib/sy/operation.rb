module Sy
  class Operation
    def description
      return '(no operation)'
    end

    def result_is_normal?
      return false
    end
    
    def iterate(exp)
      result = exp.deep_clone

      while true
        pass = self.single_pass(result)
        break if pass.nil?
        result = pass
      end

      return result
    end

    def act_subexpressions(exp)
      if exp.is_a?(Sy::Constant)
        return
      end
      
      if exp.is_a?(Sy::Variable)
        return
      end

      # Do operation on each argument
      newargs = exp.args.map { |a| act(a) }

      if newargs == exp.args
        return
      end

      exp.args = newargs
      return exp
    end
  end
end

require 'sy/normalization'
require 'sy/trigreduction'
require 'sy/differential'
require 'sy/integration'
require 'sy/distributivelaw'
require 'sy/combinefractions'

module Sy
  class Operator < Value
    @@actions = {
      # Expression rewriting
      :trigreduct => Sy::TrigReduction.new,
      :norm       => Sy::Normalization.new,
      :dist       => Sy::DistributiveLaw.new,
      :combfrac   => Sy::CombineFractions.new,
      # Derivation/integration
      :diff       => Sy::Differential.new,
      :int        => Sy::Integration.new,
    }

    @@builtin_operators = @@actions.keys.to_set
  end
end
