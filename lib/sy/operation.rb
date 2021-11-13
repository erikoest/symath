module Sy::Operation
  # Repeat method until there are no changes
  def iterate(method)
    ret = deep_clone.send(method)
    if ret == self
      return ret
    else
      return ret.iterate(method)
    end
  end

  # Call method recursively down the arguments of the expression
  # and call self_method on self.
  def recurse(method, self_method = method)
    if is_a?(Sy::Definition) or is_a?(Sy::Matrix)
      if self_method.nil?
        return self
      else
        return self.send(self_method)
      end
    end

    # Call method on each argument
    newargs = args.map { |a| a.send('recurse', method) }

    ret = self.deep_clone
    ret.args = newargs

    if self_method.nil?
      return ret
    else
      return ret.send(self_method)
    end
  end
end
