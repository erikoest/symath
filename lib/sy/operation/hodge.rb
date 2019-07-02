require 'sy/operation'

module Sy
  class Operation::Hodge < Operation

    def description
      return 'Hodge star operator'
    end
    
    # Calculate vector pairs from the basis
    def calculate_vector_pairs
      # Calculate all possible mappings *(A) -> s*B
      # A, B: nvectors or nforms
      # s : sign of the result vector

      # Basis to do the operation relative to
      b = Sy.get_variable(:basis.to_m)

      # Transform into vectors
      v = b.row(0).map { |i| i.name.to_m('vector') }

      # Transform into dforms
      d = b.row(0).map { |i| i.name.to_m('dform') }

      @@vector_map = {}
      @@dform_map = {}
      
      # Dimension of the basis
      dim = b.ncols
      
      # Iterate from 0 to 2**(n-1)
      # Represent A and B as arrays of indexes into the basis array. Compute all 2**dim
      # such arrays.
      (0..2**dim-1).each do |p|
        a = []
        b = []
        (0..dim-1).each do |i|
          if p[i] > 0 then
            a << i
          else
            b << i
          end
        end

        # The concatenation of A and B can be treated as a permutaton of the basis,
        # and we can calculate the sign, s, as the parity of this permutation.
        sign = Sy::Variable.permutation_parity(a + b)

        ad = a.map { |i| d[i] }.inject(:wedge)
        ad = 1.to_m if ad.nil?

        bd = b.map { |i| d[i] }.inject(:wedge)
        bd = 1.to_m if bd.nil?
        
        @@dform_map[ad] = sign.mult(bd)

        av = a.map { |i| v[i] }.inject(:wedge)
        av = 1.to_m if av.nil?

        bv = b.map { |i| v[i] }.inject(:wedge)
        bv = 1.to_m if bv.nil?

        @@vector_map[av] = sign.mult(bv)
      end
    end

    def act(exp)
      # Replace nvectors and nforms with their hodge dual

      # Product expressions are split into a scalar part which is kept and a vector part which
      # is replaced with its hodge dual
      if exp.is_prod_exp?
        s = exp.scalar_factors_exp
        c = exp.coefficient.to_m
        dc = exp.div_coefficient.to_m
        # Normalize the vector factors
        w = Sy::Variable.normalize_vectors(exp.vector_factors.to_a)

        ret = exp.sign.to_m.mult(c.mult(s).div(dc))

        # The vector product can be negative after normalization. Move the sign
        # part from the vector prod over to the scalar before mapping vectors
        if w.is_a?(Sy::Minus)
          ret = ret.mult(-1.to_m)
          w = w.args[0]
        end
        
        if @@vector_map.key?(w)
          return ret.mult(@@vector_map[w])
        end

        if @@dform_map.key?(w)
          return ret.mult(@@dform_map[w])
        end

        raise 'Cannot find dual for unknown vector ' + w.to_s
      end

      # Recurse down sums and subtractions
      if exp.is_sum_exp?
        act_subexpressions(exp)
        return exp
      end

      # Other operators and functions are ignored
      return exp
    end
  end
end
