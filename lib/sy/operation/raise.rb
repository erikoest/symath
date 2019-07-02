require 'sy/operation'

module Sy
  class Operation::Raise < Operation

    def description
      return 'Calculate \'sharp\' contra-variant vector from covariant dual'
    end

    def calc_basic_vectors
      # Calculate vector components for each of the dform bases
      n = Sy::Operation::Normalization.new
      
      # A row matrix of bases. These are scalar variables. We will need
      # to convert them to vectors and dforms
      b = Sy.get_variable(:basis.to_m)

      # Get the inverse metric tensor
      g = Sy.get_variable(:g.to_m).inverse

      # Create column matrices of the basis vectors and dforms
      v = b.row(0).map { |r| r.name.to_m('vector') }
      d = b.row(0).map { |r| r.name.to_m('dform') }

      # Calculate raised vectors from metric tensor
      raised = n.act(g.mult(Sy::Matrix.new(v).transpose)).col(0)

      # Map dforms to raised vectors
      @vectormap = (0..b.ncols-1).map { |r| [d[r], raised[r]] }.to_h
    end
    
    def act(exp)
      act_subexpressions(exp)

      if exp.is_a?(Sy::Variable)
        if exp.type.is_subtype?('dform')
          if @vectormap.key?(exp)
            return @vectormap[exp]
          else
            raise 'Cannot raise unknown dform ' + exo.to_s
          end
        end
      end

      return exp
    end
  end
end
