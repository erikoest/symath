require 'sy/value'
require 'sy/type'

module Sy
  class Definition::Variable < Definition

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

    # Re-calculate various auxiliary data structured based on the given basis
    # This does not scale for higher dimensions, but that will most probably
    # be out of scope for this library anyway.
    def self.recalc_basis_vectors()
      b = Sy.get_variable(:basis)
      g = Sy.get_variable(:g)

      brow = b.row(0)
      dim = brow.length

      dmap = brow.map do |bb|
        "d#{bb.name}".to_sym.to_m('dform')
      end

      vmap = brow.map do |bb|
        bb.name.to_sym.to_m('vector')
      end

      # Hash up the order of the basis vectors
      @@basis_order = {}

      (0..dim - 1).each do |i|
        @@basis_order[brow[i].name.to_sym] = i
        @@basis_order["d#{brow[i].name}".to_sym] = i
      end

      # Calculate all possible permutations of all possible combinations of
      # the basis vectors (including no vectors).
      @@norm_map = {}
      @@hodge_map = {}
      (0..dim).each do |d|
        (0..dim - 1).to_a.permutation(d).each do |p|
          if p.length == 0
            @@norm_map[1.to_m] = 1.to_m
            @@hodge_map[1.to_m] = dmap.inject(:^)
            next
          end

          # Hash them to the normalized expression (including the sign).
          # Do this both for vectors and dforms.      
          norm = p.sort
          sign = permutation_parity(p)

          dform = p.map { |i| dmap[i] }.inject(:^)
          vect = p.map { |i| vmap[i] }.inject(:^)

          dnorm = sign*(norm.map { |i| dmap[i] }.inject(:^))
          vnorm = sign*(norm.map { |i| vmap[i] }.inject(:^))

          @@norm_map[dform] = dnorm
          @@norm_map[vect] = vnorm

          # Hash them to their hodge dual
          dual = (0..dim - 1).to_a - norm
          dsign = permutation_parity(p + dual)
          
          if dual.length == 0
            hdd = sign
            hdv = sign
          else
            hdd = sign*dsign*(dual.map { |i| dmap[i] }.inject(:^))
            hdv = sign*dsign*(dual.map { |i| vmap[i] }.inject(:^))
          end

          @@hodge_map[dform] = hdd
          @@hodge_map[vect] = hdv
        end
      end

      # Calculate the musical isomorphisms. Hash up the mappings both ways.
      flat = (g*Sy::Matrix.new(dmap).transpose).evaluate.normalize.col(0)
      sharp = (g.inverse*Sy::Matrix.new(vmap).transpose).evaluate.
                normalize.col(0)

      @@flat_map = (0..dim - 1).map { |i| [vmap[i], flat[i]] }.to_h
      @@sharp_map = (0..dim - 1).map { |i| [dmap[i], sharp[i]] }.to_h
    end

    # Return the hodge dual of an expression consisting only of basis vectors
    # or basis dforms
    def self.hodge_dual(exp)
      if !@@hodge_map.key?(exp)
        raise 'No hodge dual for ' + exp.to_s
      end

      return @@hodge_map[exp]
    end
    
    attr_reader :name
    attr_reader :type
  
    def initialize(name, t = 'real')
      @type = t.to_t
      super(name, define_symbol: false)
    end

    def description()
      return "#{name} - free variable"
    end

    def call(*args)
      return Sy::Operator.create(self, args.map { |a| a.nil? ? a : a.to_m })
    end

    def ==(other)
      return false if self.class.name != other.class.name
      return false if @type != other.type
      return @name == other.name
    end

    def <=>(other)
      if self.class.name != other.class.name
        return super(other)
      end

      if type.name != other.type.name
        return type.name <=> other.type.name
      end
      # Order basis vectors and basis dforms by basis order
      if type.is_subtype?('vector') or type.is_subtype?('dform')
        bv1 = @@basis_order.key?(@name)
        bv2 = @@basis_order.key?(other.name)

        if !bv1 and bv2
          # Order basis vectors higher than other vectors
          return 1
        elsif bv1 and !bv2
          # Order basis vectors higher than other vectors
          return -1
        elsif bv1 and bv2
          return @@basis_order[@name] <=> @@basis_order[other.name]
        end
      end

      return @name.to_s <=> other.name.to_s
    end

    def is_constant?(vars = nil)
      return false if vars.nil?
      return !(vars.member?(self))
    end

    # Returns true if variable is a differential form
    def is_d?()
      return @type.is_dform?
    end

    # Returns variable which differential is based on
    def undiff()
      n = "#{@name}"
      if n[0] == 'd'
        n = n[1..-1]
      end

      n.to_sym.to_m(:real)
    end
    
    def to_d()
      return "d#{@name}".to_sym.to_m(:dform)
    end

    # Return the vector dual of the dform
    def raise_dform()
      if !@@sharp_map.key?(self)
        raise 'No vector dual for ' + to_s
      end

      return @@sharp_map[self]
    end

    # Return the dform dual of the vector
    def lower_vector()
      if !@@flat_map.key?(self)
        raise 'No dform dual for ' + to_s
      end

      return @@flat_map[self]
    end
    
    def variables()
      return [@name]
    end

    def replace(map)
      if is_d?
        u = undiff
        if map.key?(u)
          return op(:d, map[u].deep_clone)
        else
          return self
        end
      end

      if map.key?(self)
        return map[self].deep_clone
      else
        return self
      end
    end

    def to_s()
      if @type.is_dform?
        return Sy.setting(:d_symbol) + undiff.to_s
      elsif @type.is_vector?
        return @name.to_s + Sy.setting(:vector_symbol)
      elsif @type.is_covector?
        return @name.to_s + Sy.setting(:covector_symbol)
      elsif @type.is_subtype?('tensor')
        return @name.to_s + '['.to_s + @type.index_str + ']'.to_s
      else
        return @name.to_s
      end
    end

    def to_latex()
      if type.is_dform?
        return '\mathrm{d}' + undiff.to_latex
      elsif @type.is_vector?
        return '\vec{'.to_s + @name.to_s + '}'.to_s
      elsif @type.is_covector?
        # What is the best way to denote a covector without using indexes?
        return '\vec{'.to_s + @name.to_s + '}'.to_s
      elsif @type.is_subtype?('tensor')
        return @name.to_s + '['.to_s + @type.index_str + ']'.to_s
      else
        return @name.to_s
      end
    end

    alias eql? ==
  end
end

class Symbol
  def to_m(type = 'real')
    begin
      # Look up the already defined symbol
      # (we might want to check that it is a constant or variable)
      return Sy::Definition.get(self)
    rescue
      # Not defined. Define it now.
      return Sy::Definition::Variable.new(self, type)
    end
  end
end
