require 'symath/definition/qlogicgate'

module SyMath
  class Definition::QY < Definition::QLogicGate
    @@product_reductions = {}

    @@matrix_form = nil

    def self.reductions()
      return @@reductions
    end

    def self.initialize()
      ql = SyMath.get_vector_space('quantum_logic')

      @@product_reductions = {
        ql.vector(:q0)     => :i*ql.vector(:q1),
        ql.vector(:q1)     => -:i*ql.vector(:q0),
        ql.vector(:qminus) => :i*ql.vector(:qplus),
        ql.vector(:qplus)  => -:i*ql.vector(:qminus),
        ql.vector(:qleft)  => -ql.vector(:qleft),
        ql.vector(:qright) => ql.vector(:qright),
        ql.linop(:qX)      => -:i*ql.linop(:qY),
        ql.linop(:qY)      => 1.to_m,
        ql.linop(:qZ)      => :i*ql.linop(:qX),
      }

      @@matrix_form = [[0, -:i],
                       [:i,  0]].to_m
    end

    def to_matrix
      return @@matrix_form
    end

    def product_reductions()
      return @@product_reductions
    end

    def initialize()
      super(:qY, type: 'linop')
    end

    def is_involutory?
      return true
    end
  end
end
