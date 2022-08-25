require 'symath/definition/qlogicgate'

module SyMath
  class Definition::QZ < Definition::QLogicGate
    @@reductions = {}

    @@matrix_form = nil

    def self.reductions()
      return @@product_reductions
    end

    def self.initialize()
      @@product_reductions = {
        :q0.to_m('vector')     => :q0.to_m('vector'),
        :q1.to_m('vector')     => -:q1.to_m('vector'),
        :qminus.to_m('vector') => :qplus.to_m('vector'),
        :qplus.to_m('vector')  => :qminus.to_m('vector'),
        :qleft.to_m('vector')  => :qright.to_m('vector'),
        :qright.to_m('vector') => :qleft.to_m('vector'),
        :qX.to_m('linop')      => :i*:qY.to_m('linop'),
        :qY.to_m('linop')      => -:i*:qX.to_m('linop'),
        :qZ.to_m('linop')      => 1.to_m,
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
