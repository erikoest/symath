require 'symath/definition/qlogicgate'

module SyMath
  class Definition::QZ < Definition::QLogicGate
    @@reductions = {}

    @@matrix_form = nil

    def self.reductions()
      return @@product_reductions
    end

    def self.initialize()
      ql = SyMath.get_vector_space('quantum_logic')

      @@product_reductions = {
        ql.vector(:q0)     => ql.vector(:q0),
        ql.vector(:q1)     => -ql.vector(:q1),
        ql.vector(:qminus) => ql.vector(:qplus),
        ql.vector(:qplus)  => ql.vector(:qminus),
        ql.vector(:qleft)  => ql.vector(:qright),
        ql.vector(:qright) => ql.vector(:qleft),
        ql.linop(:qX)      => :i*ql.linop(:qY),
        ql.linop(:qY)      => -:i*ql.linop(:qX),
        ql.linop(:qZ)      => 1.to_m,
      }

      @@matrix_form = [[1,  0],
                       [0, -1]].to_m
    end

    def to_matrix
      return @@matrix_form
    end

    def product_reductions()
      return @@product_reductions
    end

    def initialize()
      super(:qZ, type: 'linop')
    end

    def is_involutory?
      return true
    end
  end
end
