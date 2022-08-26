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
        return res.vector_space.lower_vector(res)
      end
    end
    
    return res
  end

  # Raise indices, transforming differential forms to vectors
  def sharp()
    res = recurse('sharp', nil)

    if res.is_a?(SyMath::Definition::Variable)
      if res.type.is_subtype?('dform')
        return res.vector_space.raise_dform(res)
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
    elsif is_prod_exp?
      # Assume that the wedge expression is always on the right hand side
      return factor1*factor2.hodge
    else
      if !self.type.is_subtype?('nform')
        return self*SyMath.get_vector_space.hodge_dual(1.to_m)
      end

      # FIXME: If expression is a product of sums, expand the product first
      # (distributive law), then hodge op on the new sum.
      return SyMath.get_vector_space.hodge_dual(self)
    end
  end
end
