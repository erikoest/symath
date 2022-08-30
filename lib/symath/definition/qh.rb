require 'symath/definition/qlogicgate'

module SyMath
  class Definition::QH < Definition::QLogicGate
    @@reductions = {}

    @@matrix_form = nil

    def self.reductions()
      return @@product_reductions
    end

    def self.initialize()
      ql = SyMath.get_vector_space('quantum_logic')

      @@product_reductions = {
        ql.vector(:q0)     => ql.vector(:qplus),
        ql.vector(:q1)     => ql.vector(:qminus),
        ql.vector(:qminus) => ql.vector(:q1),
        ql.vector(:qplus)  => ql.vector(:q0),
        ql.linop(:qH)      => 1.to_m,
      }

      @@matrix_form = 1.to_m/fn(:sqrt, 2)*[[1,  1],
                                           [1, -1]].to_m
    end

    def to_matrix
      return @@matrix_form
    end

    def product_reductions()
      return @@product_reductions
    end

    def initialize()
      super(:qH, type: 'linop')
    end

    def is_involutory?
      return true
    end
  end
end
