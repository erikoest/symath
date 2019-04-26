module Sy
  class Operation
    def deep_clone(exp)
      return Marshal.load(Marshal.dump(exp))
    end
  end
end
