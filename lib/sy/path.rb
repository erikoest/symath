module Sy
  class Path
    attr_reader :path
    attr_reader :pos
    
    def initialize(path, pos = nil)
      @path = path
      @pos = pos
    end

    def length()
      return @path.length
    end
    
    # Add a path level on left hand side
    def unshift(val)
      @path.unshift(val)
      return self
    end

    # Add one level to path
    def push(value)
      @path.push(value)
      return self
    end

    # Remove lowest level in path
    def pop()
      return @path.pop
    end
    
    def <=>(other)
      return @path <=> other.path
    end
  end
end
