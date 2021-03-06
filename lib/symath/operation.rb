module SyMath::Operation
  # Repeat method until there are no changes
  def iterate(method, *args)
    ret = deep_clone.send(method, *args)
    if ret == self
      return ret
    else
      return ret.iterate(method, *args)
    end
  end

  # Call method recursively down the arguments of the expression
  # and call self_method on self.
  def recurse(method, self_method = method)
    if is_a?(SyMath::Definition) or is_a?(SyMath::Matrix)
      if self_method.nil?
        return self
      else
        ret = self.send(self_method)
        return ret
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
