require 'symath/definition/qlogicgate'

module SyMath
  class Definition::QS < Definition::QLogicGate
    @@product_reductions = {}

    def self.initialize()
      @@product_reductions = {
        :q0.to_m('vector')     => :q0.to_m('vector'),
        :q1.to_m('vector')     => :i*:q1.to_m('vector'),
        :qminus.to_m('vector') => :qleft.to_m('vector'),
        :qplus.to_m('vector')  => :qright.to_m('vector'),
        :qleft.to_m('vector')  => :qplus.to_m('vector'),
        :qright.to_m('vector') => :qminus.to_m('vector'),
        :qS.to_m('linop')      => :qZ.to_m('linop'),
      }
    end

    def reduce_power_modulo_sign(e)
      if e.is_number?
        if e.value % 4 == 0
          return 1.to_m, 1, true
        elsif e.value % 2 == 0
          return :qZ.to_m('linop'), 1, true
        end
      end

      return self, 1, true
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
