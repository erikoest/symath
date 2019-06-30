require 'sy/operation'

module Sy
  class Operation::Raise < Operation

    def description
      return 'Calculate ''sharp'' contra-variant vector from covariant dual'
    end

    def act(exp)
      # Calculate vector components for each of the dform bases
      # FIXME: This should be done before the recursive call to act()
      # A row matrix of bases. These are scalar variables. We will need
      # to convert them to vectors and dforms
      b = Sy.get_variable('basis')
      # Get the inverse metric tensor
      g = Sy.get_variable('g').inverse
      # Create column matrices of the basis vectors and dforms
      # v = b.each ...
      # d = b.each ...
      # Hash d => g.mult(v)
      # Replace all occurences in exp of d with d => 
      
      act_subexpression(exp)

      if exp.is_a?(Sy::Variable)
        if exp.type.is_subtype?('dform')

        end
      end
    end
  end
end
