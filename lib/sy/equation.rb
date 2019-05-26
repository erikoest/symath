require 'sy/value'
require 'sy/operator'

module Sy
  class Equation < Operator
    def initialize(arg1, arg2)
      super('=', [arg1, arg2])
    end

    def to_s()
      return @args[0].to_s + ' = ' + @args[1].to_s
    end
  end
end
