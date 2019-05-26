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
