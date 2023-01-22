require 'symath/definition/qlogicgate'

module SyMath
  class Definition::QX < Definition::QLogicGate
    @@product_reductions = {}

    @@matrix_form = nil

    def self.initialize()
      ql = SyMath.get_vector_space('quantum_logic')

      @@product_reductions = {
        ql.vector(:q0)     => ql.vector(:q1),
        ql.vector(:q1)     => ql.vector(:q0),
        ql.vector(:qminus) => ql.vector(:qplus),
        ql.vector(:qplus)  => ql.vector(:qminus),
        ql.vector(:qleft)  => ql.vector(:qleft),
        ql.vector(:qright) => ql.vector(:qright),
        ql.linop(:qX)      => 1.to_m,
        ql.linop(:qY)      => :i*ql.linop(:qZ),
        ql.linop(:qZ)      => -:i*ql.linop(:qY),
      }

      @@matrix_form = [[0, 1],
                       [1, 0]].to_m
    end

    def to_matrix
      return @@matrix_form
    end

    def product_reductions()
      return @@product_reductions
    end

    def initialize()
      super(:qX, type: 'linop'.to_t(indexes: ['u', 'l']))
    end

    def is_involutory?
      return true
    end
  end
end
