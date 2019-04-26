require 'sy/function'

module Sy
  class Constant < Function
    def initialize(name)
      super(name, [])
    end

    def ==(other)
      return false if other.class != self.class

      return other.name == self.name
    end

    def to_s()
      return @name.to_s
    end
  end
end
