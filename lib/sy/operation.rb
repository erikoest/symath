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

    puts "subexpressions"
    puts self.to_s
    # Call method on each argument
    newargs = args.map { |a| a.send(method) }
    puts newargs.map { |a| a.to_s }.to_s

    if newargs == args
      return
    end

    ret = self.deep_clone
    ret.args = newargs
    
    return ret
  end
end
