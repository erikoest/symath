require 'symath/definition/operator'

module SyMath
  class Definition::QLogicGate < Definition::Operator
    def self.initialize()
      SyMath::Definition::QX.initialize
      SyMath::Definition::QY.initialize
      SyMath::Definition::QZ.initialize
      SyMath::Definition::QH.initialize
      SyMath::Definition::QS.initialize
      SyMath::Definition::QCNOT.initialize
    end

    def is_unitary?()
      return true
    end
  end
end

require 'symath/definition/qx'
require 'symath/definition/qy'
require 'symath/definition/qz'
require 'symath/definition/qh'
require 'symath/definition/qs'
require 'symath/definition/qcnot'
