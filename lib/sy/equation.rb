require 'sy/value'
require 'sy/operator'

module Sy
  class Equation < Operator
    def initialize(arg1, arg2)
      super('=', [arg1, arg2])
    end

    def to_s()
      return "#{@args[0]} = #{@args[1]}"
    end

    def to_latex()
      return "#{@args[0]} = #{@args[1]}"
    end
  end
end
