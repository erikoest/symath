require 'symath/definition/qlogicgate'

module SyMath
  class Definition::QX < Definition::QLogicGate
    @@product_reductions = {}

    def self.initialize()
      @@product_reductions = {
        :q0.to_m('vector')     => :q1.to_m('vector'),
        :q1.to_m('vector')     => :q0.to_m('vector'),
        :qminus.to_m('vector') => :qplus.to_m('vector'),
        :qplus.to_m('vector')  => :qminus.to_m('vector'),
        :qleft.to_m('vector')  => :qleft.to_m('vector'),
        :qright.to_m('vector') => :qright.to_m('vector'),
        :qX.to_m('linop')      => 1.to_m,
        :qY.to_m('linop')      => :i*:qZ.to_m('linop'),
        :qZ.to_m('linop')      => -:i*:qY.to_m('linop'),
      }
    end

    def product_reductions()
      return @@product_reductions
    end

    def initialize()
      super(:qX, type: 'linop')
    end

    def is_involutory?
      return true
    end
  end
end
