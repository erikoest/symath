require 'sy/function'

module Sy
  class Constant < Function
    def initialize(name)
      super(name, [])
    end

    def has_definition?()
      return false
    end

    def to_s()
      return @name.to_s
    end

    def to_latex()
      return @name.to_s
    end
  end
end
