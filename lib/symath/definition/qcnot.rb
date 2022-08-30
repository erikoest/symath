require 'symath/definition/qlogicgate'

module SyMath
  class Definition::QCNOT < Definition::QLogicGate
    @@product_reductions = {}

    @@matrix_form = nil

    def self.initialize()
      ql = SyMath.get_vector_space('quantum_logic')
      q0     = ql.vector(:q0)
      q1     = ql.vector(:q1)
      qplus  = ql.vector(:qplus)
      qminus = ql.vector(:qminus)

      @@product_reductions = {
        q0.outer(q0)         => q0.outer(q0),
        q0.outer(q1)         => q0.outer(q1),
        q1.outer(q0)         => q1.outer(q1),
        q1.outer(q1)         => q1.outer(q0),
        q0.outer(qminus)     => q0.outer(qminus),
        q0.outer(qplus)      => q0.outer(qplus),
        q1.outer(qminus)     => -q1.outer(qminus),
        q1.outer(qplus)      => q1.outer(qplus),
        qminus.outer(qminus) => qplus.outer(qminus),
        qminus.outer(qplus)  => qminus.outer(qplus),
        qplus.outer(qminus)  => qminus.outer(qminus),
        qplus.outer(qplus)   => qplus.outer(qplus),
      }

      @@matrix_form = [[1, 0, 0, 0],
                       [0, 1, 0, 0],
                       [0, 0, 0, 1],
                       [0, 0, 1, 0]].to_m
    end

    def product_reductions()
      return @@product_reductions
    end

    def to_matrix
      return @@matrix_form
    end

    def initialize()
      super(:qCNOT, type: 'linop')
    end

    def is_involutory?
      return false
    end
  end
end
