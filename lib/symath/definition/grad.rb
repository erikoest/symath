require 'symath/value'
require 'symath/definition/operator'

module SyMath
  class Definition::Grad < Definition::Operator
    def initialize()
      # Grad is defined as (dF)#
      super(:grad, args: [:f], exp: '#(xd(f))')
    end

    def description()
      return 'grad(f) - gradient of scalar field f'
    end

    def to_latex(args)
      if !args
        args = @args
      end

      return "\\nabla #{args[0].to_latex}"
    end
  end
end
