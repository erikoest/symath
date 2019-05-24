require 'sy/value'
require 'sy/operator'

module Sy
  class Diff < Operator
    def initialize(arg)
      super('diff', [arg])
    end
  end
end
