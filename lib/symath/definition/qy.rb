require 'symath/definition/qlogicgate'

module SyMath
  class Definition::QY < Definition::QLogicGate
    @@product_reductions = {}

    @@matrix_form = nil

    def self.reductions()
      return @@reductions
    end

    def self.initialize()
      @@product_reductions = {
        :q0.to_m('vector')     => :i.to_m*:q1.to_m('vector'),
        :q1.to_m('vector')     => -:i*:q0.to_m('vector'),
        :qminus.to_m('vector') => :i*:qplus.to_m('vector'),
        :qplus.to_m('vector')  => -:i*:qminus.to_m('vector'),
        :qleft.to_m('vector')  => -:qleft.to_m('vector'),
        :qright.to_m('vector') => :qright.to_m('vector'),
        :qX.to_m('linop')      => -:i*:qY.to_m('linop'),
        :qY.to_m('linop')      => 1.to_m,
        :qZ.to_m('linop')      => :i*:qX.to_m('linop'),
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
