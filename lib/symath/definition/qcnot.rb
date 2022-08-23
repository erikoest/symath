require 'symath/definition/qlogicgate'

module SyMath
  class Definition::QCNOT < Definition::QLogicGate
    @@product_reductions = {}

    def self.initialize()
      @@product_reductions = {
        :q0.to_m('vector')     => 1.to_m,
        :q1.to_m('vector')     => :qX.to_m('linop'),
      }
    end

    def product_reductions()
      return @@product_reductions
    end

    def initialize()
      super(:qCNOT, type: 'linop')
    end

    def is_involutory?
      return false
    end
  end
end
