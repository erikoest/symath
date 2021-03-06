require 'symath/value'
require 'symath/definition/operator'

module SyMath
  class Definition::Laplacian < Definition::Operator
    def initialize()
      # The laplacian is defined as *d*dF
      super(:laplacian, args: [:f], exp: 'hodge(xd(hodge(xd(f))))')
    end

    def description()
      return 'laplacian(f) - laplacian of function f'
    end

    def to_latex(args)
      if !args
        args = @args
      end

      return "\\nabla^2 #{args[0].to_latex}"
    end
  end
end
