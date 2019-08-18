require 'sy/operation'

module Sy::Operation::Exterior
  # This operation module provides methods for calculating the musical
  # isomorphisms and the hodge star isomorphisms of exterior algebra
  # expressions.

  # Lower indices, transforming vectors to differential forms
  def flat()
    res = act_subexpressions('flat')
    res = deep_clone if res.nil?

    if res.is_a?(Sy::Variable)
      if res.type.is_subtype?('vector')
        return res.lower_vector
      end
    end
    
    return res
  end

  # Raise indices, transforming differential forms to vectors
  def sharp()
    res = act_subexpressions('sharp')
    res = deep_clone if res.nil?

    if res.is_a?(Sy::Variable)
      if res.type.is_subtype?('dform')
        return res.raise_dform
      end
    end

    return res
  end

  # Calculate hodge star duality
  def hodge()
    # Recurse down sums and subtractions
    if is_sum_exp?
      return act_subexpressions('hodge')
    else
      # Replace nvectors and nforms with their hodge dual
      s = scalar_factors_exp
      c = coefficient.to_m
      dc = div_coefficient.to_m
      h = Sy::Variable.hodge_dual(vector_factors_exp)
      return sign.to_m*c*s*h/dc
    end
  end
end
