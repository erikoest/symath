require 'sy/operation'

module Sy::Operation::Match
  include Sy::Operation

  def build_assoc_op(args, opclass)
    e = args[-1]
    if args.length > 1
      args[0..-2].each do |a|
        e = opclass.new(a, e)
      end
    end

    return e
  end

  # Match the lists of arguments of two associative operators, binding the
  # free variables in args2 to expressions in args1. Because of the
  # associativity property, multiple matches may be possible. E.g.
  # [x, y, z] == [a, b] gives two possible matches: a = (x op y), b = z or
  # a = x, b = (y op z)
  # A list of hashes is returned, each hash representing a match.
  def match_assoc(args1, args2, freevars, boundvars, opclass)
    # If args1 is shorter than args2 we do not have enough arguments for a
    # match
    return if args1.length < args2.length

    # If args2 has only one argument, it must match the whole list of args1
    if args2.length == 1
      return build_assoc_op(args1, opclass).match(
               args2[0], freevars, boundvars)
    end

    ret = []
    all = (0..args1.length - 1).to_a
    fv = freevars
    bv = boundvars

    (1..args1.length - args2.length + 1).each do |n|
      # Match args1[0..m] with args2[0]
      if is_commutative?
        # Select all combinations of n arguments
        sel = all.combination(n)
      else
        # Non-commutative operation. Make one selection of the
        # first n arguments
        sel = [(0..n - 1).to_a]
      end

      # Iterate over all selections and find all possible matches
      sel.each do |s|
        select1 = s.map { |i| args1[i] }
        remain1 = (all - s).map { |i| args1[i] }

        if n == 1
          m0 = select1[0].match(args2[0], freevars, boundvars)
        else
          if args2[0].is_a?(Sy::Variable) and freevars.include?(args2[0])
            # Register match.
            m0 = [{ args2[0] => build_assoc_op(select1, opclass) }]
          elsif args2[0].class == opclass
            m0 = match_assoc(select1, args2[0].args_assoc, freevars,
                             boundvars, opclass)
          else
            # No match. Skip to the next argument combination
            next
          end
        end

        # Set of matches is empty. Return negative
        next if m0.nil?

        # For each possible first argument match, we build new lists of free
        # and bound variables and try to match the rest of the remaining list
        # of the argument recursively.
        m0.each do |m|
          fv = freevars - m.keys
          bv = boundvars.merge(m)
          mn = match_assoc(remain1, args2[1..-1], fv, bv, opclass)
          if mn.nil?
            # No match. Skip to the next argument combination
            next
          else
            # We have a complete match. Store it in res, and continue
            m0.each do |m0i|
              mn.each do |mni|
                ret << m0i.merge(mni)
              end
            end
          end
        end
      end
    end

    return if ret.empty?
    
    return ret
  end
  
  # Match self with an expression and a set of free variables. A match is
  # found if each of the free variables can be replaced with subexpressions
  # making the expression equal to self. In that case, a hash is returned
  # mapping each of the variables to the corresponding subexpression. If no
  # match is found, nil is returned. An optional boundvars hash contains a
  # map of variables to expressions which are required to match exactly.
  def match(exp, freevars, boundvars = {})
    # Traverse self and exp in parallel. Match subexpressions recursively,
    # and match end nodes one by one. The two value nodes are compared for
    # equality and each argument are matched recursively.
    # Constant: Just match nodes by exact comparison
    if exp.is_a?(Sy::Constant)
      # Node is a constant. Exact match is required
      if (self == exp)
        # Return match with no variable bindings
        return [{}]
      else
        return
      end
    end

    # Variable: If it is a free variable, it is a match. We remove it from
    # the freevars set and add it to the boundvars set together with the
    # expression it matches. If it is a bound variable, we require that
    # the expression matches the binding.
    if exp.is_a?(Sy::Variable)
      # Node is a variable
      if freevars.include?(exp)
        # Node is a free variable. Return binding.
        return [{ exp => self }]
      elsif boundvars.key?(exp)
        # Node is a bound variable. Check that self matches the binding.
        if boundvars[exp] == self
          return [{}]
        else
          return
        end
      else
        # Node is an unknown variable. Exact match is required
        return (exp == self)? [{}] : nil
      end
    end

    # Operator. Compare class and name. Then compare each argument
    if exp.is_a?(Sy::Operator)
      # Node is an operator. Check class and name.
      if self.class != exp.class or self.name != exp.name
        return
      end

      # The args_assoc method takes care of associativity by returning the
      # argument list of all directly connected arguments.
      self_args = self.args_assoc
      exp_args = exp.args_assoc
      ret = {}
      m = match_assoc(self_args, exp_args, freevars, boundvars, self.class)
      
      return if m.nil?

      return m.map { |r| boundvars.merge(r) }
    end

    raise 'Don\'t know how to compare value type ' + exp.class.to_s
  end
end
