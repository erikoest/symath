module Sy
  class Operation
    def deep_clone(exp)
      return Marshal.load(Marshal.dump(exp))
    end

    def description
      return '(no operation)'
    end

    def result_is_normal?
      return false
    end
    
    def iterate(exp)
      result = self.deep_clone(exp)

      while true
        pass = self.single_pass(result)
        break if pass.nil?
        result = pass
      end

      return result
    end

    def act_subexpressions(exp)
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
