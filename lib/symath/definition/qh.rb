require 'symath/definition/qlogicgate'

module SyMath
  class Definition::QH < Definition::QLogicGate
    @@reductions = {}

    @@matrix_form = nil

    def self.reductions()
      return @@product_reductions
    end

    def self.initialize()
      @@product_reductions = {
        :q0.to_m('vector')     => :qplus.to_m('vector'),
        :q1.to_m('vector')     => :qminus.to_m('vector'),
        :qminus.to_m('vector') => :q1.to_m('vector'),
        :qplus.to_m('vector')  => :q0.to_m('vector'),
        :qH.to_m('linop')      => 1.to_m,
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
