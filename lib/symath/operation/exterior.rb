require 'symath/operation'

module SyMath::Operation::Exterior
  # This operation module provides methods for calculating the musical
  # isomorphisms and the hodge star isomorphisms of exterior algebra
  # expressions.

  # Lower indices, transforming vectors to differential forms
  def flat()
    res = recurse('flat', nil)

    if res.is_a?(SyMath::Definition::Variable)
      if res.type.is_subtype?('vector')
        return res.lower_vector
      end
    end
    
    return res
  end

  # Raise indices, transforming differential forms to vectors
  def sharp()
    res = recurse('sharp', nil)

    if res.is_a?(SyMath::Definition::Variable)
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
      return terms.map do |t|
        if t.is_a?(SyMath::Minus)
          - t.argument.hodge
        else
          t.hodge
        end
      end.inject(:+)
    else
      # FIXME: If expression is a product of sums, expand the product first
      # (distributive law), then hodge op on the new sum.
      
      # Replace nvectors and nforms with their hodge dual
      s = []
      v = []
      factors.each do |f|
        if f.type.is_vector? or f.type.is_dform?
          v.push f
        else
          s.push f
        end
      end
      
      h = SyMath::Definition::Variable.hodge_dual(v.inject(1.to_m, :*))
      return s.inject(1.to_m, :*)*h
    end
  end
end
