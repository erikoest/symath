require 'symath/definition'

# Hermitian adjoint

module SyMath
  class Definition::Herm < Definition::Operator
    def initialize()
      super(:Herm, args: [:o], description: 'Hermitian adjoint, Herm(o)')
    end

    # FIXME: raise error if operator is used as a leaf node (that is,
    # without arguments).

    def reduce_call(c)
      arg = c.args[0]
      if arg.is_a?(SyMath::Matrix)
        # FIXME: Reduction rules for hermitian conjugate on matrices...
        return self
      end

      # H(H(a)) -> a
      # FIXME: Use the is_involutory? property
      if arg.is_a?(SyMath::Operator) and
        arg.definition.is_a?(SyMath::Definition::Herm)
        return arg.args[0]
      end

      # c is unitary: H(c) -> c**-1
      if arg.is_a?(SyMath::Definition::Variable) and arg.is_unitary?
        if arg.type.is_vector?
          # Ket -> bra
          return arg.name.to_sym.to_m(:covector, arg.vector_space)
        elsif arg.type.is_covector?
          # Bra -> ket
          return arg.name.to_sym.to_m(:vector, arg.vector_space)
        end
      end

      if arg.is_a?(SyMath::Definition::Operator) and arg.is_unitary?
        return arg**-1.to_m
      end

      # Herm(- a) = - Herm(a)
      if arg.is_a?(SyMath::Minus)
        return - op(:Herm, arg.argument)
      end

      # a and b are bounded:
      #   Herm(a outer b) -> Herm(b) outer Herm(a)
      #   Herm(a * b) -> Herm(b) * Herm(a)
      #   Herm(a ^ b) -> Herm(b) ^ Herm(a)
      if arg.is_a?(SyMath::Product) and
        arg.factor1.is_bounded? and arg.factor2.is_bounded?
        return arg.class.new(op(:Herm, arg.factor2), op(:Herm, arg.factor1))
      end

      # FIXME: a is self adjoint: H(a) -> a
      return c
    end

    def to_latex(args)
      if args[0].is_a?SyMath::Definition
        return "#{args[0]}^\\dag"
      else
        return "\\left(#{args[0]}\\right)^\\dag"
      end
    end
  end
end
