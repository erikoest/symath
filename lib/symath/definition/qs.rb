require 'symath/definition/qlogicgate'

module SyMath
  class Definition::QS < Definition::QLogicGate
    @@product_reductions = {}

    @@matrix_form = nil

    def self.initialize()
      ql = SyMath.get_vector_space('quantum_logic')

      @@product_reductions = {
        ql.vector(:q0)     => ql.vector(:q0),
        ql.vector(:q1)     => :i*ql.vector(:q1),
        ql.vector(:qminus) => ql.vector(:qleft),
        ql.vector(:qplus)  => ql.vector(:qright),
        ql.vector(:qleft)  => ql.vector(:qplus),
        ql.vector(:qright) => ql.vector(:qminus),
        ql.linop(:qS)      => ql.linop(:qZ),
      }

      @@matrix_form = [[1,  0],
                       [0, :i]].to_m
    end

    def to_matrix
      return @@matrix_form
    end

    def reduce_power_modulo_sign(e)
      if e.is_number?
        if e.value % 4 == 0
          return 1.to_m, 1, true
        elsif e.value % 2 == 0
          return :qZ.to_m('linop'), 1, true
        end
      end

      return self, 1, false
    end

    def product_reductions()
      return @@product_reductions
    end

    def initialize()
      super(:qS, type: 'linop')
    end

    def is_involutory?
      return false
    end
  end
end
