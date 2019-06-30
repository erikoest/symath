require 'sy/operation'

module Sy
  class Operation::Lower < Operation

    def description
      return 'Calculate \'flat\' covariant vector from contra-variant dual'
    end

    def calc_basic_vectors
      # Calculate vector components for each of the dform bases
      n = Sy::Operation::Normalization.new

      # A row matrix of bases. These are scalar variables. We will need
      # to convert them to vectors and dforms
      b = Sy.get_variable(:basis.to_m)

      # Get the metric tensor
      g = Sy.get_variable(:g.to_m)

      # Create column matrices of the basis vectors and dforms
      v = b.row(0).map { |r| r.name.to_m('vector') }
      d = b.row(0).map { |r| r.name.to_m('dform') }

      # Calculate lowered vectors from metric tensor
      lowered = n.act(g.mult(Sy::Matrix.new(d).transpose)).col(0)

      # Map vector bases to lowered dforms
      @vectormap = (0..b.ncols-1).map { |r| [v[r], lowered[r]] }.to_h
    end
    
    def act(exp)
      # Replace all occurences in exp of d with d => 

      act_subexpressions(exp)

      if exp.is_a?(Sy::Variable)
        if exp.type.is_subtype?('vector') and @vectormap.key?(exp)
          return @vectormap[exp]
        end
      end

      return exp
    end
  end
end
