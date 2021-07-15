module Sy::Operation
  def iterate(method)
    result = deep_clone

    while true
      pass = result.send(method)
      break if pass.nil?
      result = pass
    end

    return result
  end

  # Call method recursively down the arguments of the expression
  def recurse(method)
    if is_a?(Sy::Constant) or is_a?(Sy::Variable)
      return self.send(method)
    end

    # Call method on each argument
    newargs = args.map { |a| a.send('recurse', method) }

    ret = self.deep_clone
    ret.args = newargs

    return ret.send(method)
  end

  def act_subexpressions(method)
    if is_a?(Sy::Constant)
      return
    end
      
    if is_a?(Sy::Variable)
      return
    end

    if is_a?(Sy::Minus)
      return -argument.send(method)
    end

    # Call method on each argument
    newargs = args.map { |a| a.send(method) }

    if newargs == args
      return
    end

    ret = self.deep_clone
    ret.args = newargs
    
    return ret
  end

  def change_or_nil(e)
    return nil if e.nil?
    e = e.to_m
    return self == e ? nil : e
  end
end
