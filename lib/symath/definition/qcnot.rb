require 'symath/definition/qlogicgate'

module SyMath
  class Definition::QCNOT < Definition::QLogicGate
    @@product_reductions = {}

    @@matrix_form = nil

    def self.initialize()
      @@product_reductions = {
        '|0,0>' => '|0,0>',
        '|0,1>' => '|0,1>',
        '|1,0>' => '|1,1>',
        '|1,1>' => '|1,0>',
        '|0,->' => '|0,->',
        '|0,+>' => '|0,+>',
        '|1,->' => '-|1,->',
        '|1,+>' => '|1,+>',
        '|-,->' => '|+,->',
        '|-,+>' => '|-,+>',
        '|+,->' => '|-,->',
        '|+,+>' => '|+,+>',
      }.map do |from, to|
        [ from.to_m, to.to_m ]
      end.to_h

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
