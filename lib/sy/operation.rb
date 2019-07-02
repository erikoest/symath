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

require 'sy/operation/normalization'
require 'sy/operation/trigreduction'
require 'sy/operation/differential'
require 'sy/operation/integration'
require 'sy/operation/distributivelaw'
require 'sy/operation/combinefractions'
require 'sy/operation/bounds'
require 'sy/operation/evaluation'
require 'sy/operation/raise'
require 'sy/operation/lower'
require 'sy/operation/hodge'

module Sy
  class Operator < Value
    @@actions = {
      # Evaluation operation
      :eval       => Sy::Operation::Evaluation.new,
      # Expression rewriting
      :trigreduct => Sy::Operation::TrigReduction.new,
      :norm       => Sy::Operation::Normalization.new,
      :dist       => Sy::Operation::DistributiveLaw.new,
      :combfrac   => Sy::Operation::CombineFractions.new,
      # Derivation/integration
      :diff       => Sy::Operation::Differential.new,
      :int        => Sy::Operation::Integration.new,
      :bounds     => Sy::Operation::Bounds.new,
      # Exterior algebra
      :raise      => Sy::Operation::Raise.new,
      :lower      => Sy::Operation::Lower.new,
      :hodge      => Sy::Operation::Hodge.new,
    }

    @@builtin_operators = @@actions.keys.to_set
  end
end
