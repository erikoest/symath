require 'sy/function'

module Sy
  class Constant < Function
    def initialize(name)
      super(name, [])
    end

    def to_s()
      return @name.to_s
    end
  end
end
