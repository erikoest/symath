module SyMath
  class VectorSpace
    attr_reader :name, :basis, :g, :dimension

    def self.initialize()
      # Initialize built-in vector spaces
      e3 = self.new('euclidean_3d', dimension: 3,
                    basis: [:x1, :x2, :x3].to_m,
                    metric: [[1, 0, 0],
                             [0, 1, 0],
                             [0, 0, 1]].to_m)

      self.new('minkowski_4d', dimension: 4,
                    basis: [:x0, :x1, :x2, :x3].to_m,
                    metric: [[-1, 0, 0, 0],
                             [ 0, 1, 0, 0],
                             [ 0, 0, 1, 0],
                             [ 0, 0, 0, 1]].to_m)

      SyMath.set_default_vector_space(e3)

      # Initialize the built-in quantum logic vector space
      SyMath::VectorSpace::QuantumLogic.initialize
    end
    
    # TODO:
    # * Is normalized the right term? Is it even correct to define the space
    #   itself as normalized, or should each element/vector be specified as
    #   normalized?

    def initialize(name, dimension: 3, basis: nil, constants: {}, metric: nil,
                   normalized: false)
      @name = name
      @dimension = dimension
      @basis = basis
      @constants = constants
      @g = metric
      @normalized = normalized

      if !basis.nil?
        if basis.ncols != dimension
          raise "Number of basis vectors #{basis.ncols} does not match dimension #{dimension}"
        end
      end

      # Hash up the order of the basis vectors
      @basis_order = {}

      (0..dimension - 1).each do |i|
        b = @basis.row(0)[i].name
        @basis_order[b.to_sym] = i
        @basis_order["d#{b}".to_sym] = i
      end

      if !metric.nil?
        recalc_basis_vectors
      end

      SyMath.register_vector_space(self)
    end

    # Return parity of permutation. Even number of permutations give
    # 1 and odd number gives -1
    def self.permutation_parity(perm)
      # perm is an array of indexes representing the permutation
      # Put permutation list into disjoint cycles form
      cycles = {}
      (0..perm.length-1).each do |i|
        cycles[perm[i]] = i
      end

      sign = 0

      # Count the number even cycles.
      (0..perm.length-1).each do |i|
        next if !cycles.key?(i)

        count = 0
        while cycles.key?(i)
          count += 1
          j = cycles[i]
          cycles.delete(i)
          i = j
        end

        if (count % 2) == 0
          sign += 1
        end
      end

      # Even => 1, Odd => -1
      sign = (1 - (sign % 2)*2).to_m
    end

    def recalc_basis_vectors()
      if @basis.nil?
        raise "Vector space has no basis. Cannot calculate metric properties."
      end

      brow = @basis.row(0)
      dim = brow.length

      dmap = brow.map do |bb|
        SyMath::Definition::Variable.new("d#{bb.name}".to_sym, 'dform'.to_t, self)
      end

      vmap = brow.map do |bb|
        SyMath::Definition::Variable.new(bb.name.to_sym, 'vector'.to_t, self)
      end

      # Calculate all possible permutations of all possible combinations of
      # the basis vectors (including no vectors).
      @norm_map = {}
      @hodge_map = {}
      (0..dim).each do |d|
        (0..dim - 1).to_a.permutation(d).each do |p|
          if p.length == 0
            @norm_map[1.to_m] = 1.to_m
            @hodge_map[1.to_m] = dmap.inject(:^)
            next
          end

          # Hash them to the normalized expression (including the sign).
          # Do this both for vectors and dforms.      
          norm = p.sort
          sign = self.class.permutation_parity(p)

          dform = p.map { |i| dmap[i] }.inject(:^)
          vect = p.map { |i| vmap[i] }.inject(:^)

          dnorm = sign*(norm.map { |i| dmap[i] }.inject(:^))
          vnorm = sign*(norm.map { |i| vmap[i] }.inject(:^))

          @norm_map[dform] = dnorm
          @norm_map[vect] = vnorm

          # Hash them to their hodge dual
          dual = (0..dim - 1).to_a - norm
          dsign = self.class.permutation_parity(p + dual)

          if dual.length == 0
            hdd = sign
            hdv = sign
          else
            hdd = sign*dsign*(dual.map { |i| dmap[i] }.inject(:^))
            hdv = sign*dsign*(dual.map { |i| vmap[i] }.inject(:^))
          end

          @hodge_map[dform] = hdd
          @hodge_map[vect] = hdv
        end
      end

      # Calculate the musical isomorphisms. Hash up the mappings both ways.
      flat = (@g*SyMath::Matrix.new(dmap).transpose).mul_mx.normalize.col(0)
      sharp = (@g.inverse*SyMath::Matrix.new(vmap).transpose).mul_mx.
                normalize.col(0)

      @flat_map = (0..dim - 1).map { |i| [vmap[i], flat[i]] }.to_h
      @sharp_map = (0..dim - 1).map { |i| [dmap[i], sharp[i]] }.to_h
    end

    def basis_order(b)
      if @basis_order.has_key?(b.name)
        return @basis_order[b.name]
      else
        return nil
      end
    end

    def hodge_dual(exp)
      if !@hodge_map.key?(exp)
        raise 'No hodge dual for ' + exp.to_s
      end

      return @hodge_map[exp]
    end

    def vector(name)
      return name.to_m('vector', self)
    end

    def covector(name)
      return name.to_m('covector', self)
    end

    def dform(name)
      return name.to_m('dform', self)
    end

    def linop(name)
      return name.to_m('linop', self)
    end

    def raise_dform(d)
      if @sharp_map.nil?
        raise "Not a metric space"
      end
      
      if !@sharp_map.key?(d)
        raise "No vector dual for #{d}"
      end

      return @sharp_map[d]
    end

    def lower_vector(v)
      if @sharp_map.nil?
        raise "Not a metric space"
      end

      if !@flat_map.key?(v)
        raise "No dform dual for #{v}"
      end

      return @flat_map[v]
    end

    def metric?()
      return !@g.nil?
    end

    def normalized?()
      return @normalized
    end

    def set_metric(g)
      @g = g

      recalc_basis_vectors
    end

    def ==(other)
      return @name == other.name
    end

    def hash()
      return @name.hash
    end

    alias eql? ==

    def product_reductions_by_variable(var)
      return
    end

    def variable_to_matrix(var)
      order = basis_order(var)
      if order
        m = [*0..@dimension - 1].map do |i|
          i == order ? 1 : 0
        end.to_m.transpose

        if var.type.is_covector?
          return m.conjugate_transpose
        else
          return m
        end
      end

      # Cannot convert to matrix
      return var
    end

    def inspect()
      if SyMath.setting(:inspect_to_s)
        return self.to_s
      else
        return super.inspect
      end
    end

    def to_s
      ret = "#{@name}"
      if @basis
        ret += " (#{@basis})"
      end

      return ret
    end
  end
end

require 'symath/vectorspace/quantumlogic'
