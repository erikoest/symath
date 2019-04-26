require 'sy/path'
# FIXME: Move parser and node into the Symm module
module Sy
  class Node
    attr_reader :val
    attr_accessor :paths

    def initialize(val, paths = nil)
      @val = val
      @paths = paths
    end
  end
end
