require 'sy/value'
require 'sy/definition/operator'

module Sy
  class Definition::Grad < Definition::Operator
    def initialize()
      # Grad is defined as (dF)#
      super(:grad, args: [:f], exp: '#(xd(f))')
    end

    def to_latex(args)
      if !args
        args = @args
      end

      return "\\nabla #{args[0].to_latex}"
    end
  end
end
