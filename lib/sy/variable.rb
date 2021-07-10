require 'sy/value'
require 'sy/type'

module Sy
  class Variable < Value

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

      # Hash up the order of the basis vectors
      @@basis_order = (0..dim - 1).map do |i|
        [brow[i].name.to_sym, i]
      end.to_h

      # Calculate all possible permutations of all possible combinations of
      # the basis vectors (including no vectors).
      @@norm_map = {}
      @@hodge_map = {}
      (0..dim).each do |d|
        (0..dim - 1).to_a.permutation(d).each do |p|
          if p.length == 0
            @@norm_map[1.to_m] = 1.to_m
            @@hodge_map[1.to_m] = brow.map { |bb| bb.name.to_m('dform') }.inject(:^)
            next
          end

          # Hash them to the normalized expression (including the sign).
          # Do this both for vectors and dforms.      
          norm = p.sort
          sign = permutation_parity(p)

          dform = p.map { |i| brow[i].name.to_m('dform') }.inject(:^)
          vect = p.map { |i| brow[i].name.to_m('vector') }.inject(:^)

          dnorm = sign*(norm.map { |i| brow[i].name.to_m('dform') }.inject(:^))
          vnorm = sign*(norm.map { |i| brow[i].name.to_m('vector') }.inject(:^))

          @@norm_map[dform] = dnorm
          @@norm_map[vect] = vnorm

          # Hash them to their hodge dual
          dual = (0..dim - 1).to_a - norm
          dsign = permutation_parity(p + dual)
          
          if dual.length == 0
            hdd = sign
            hdv = sign
          else
            hdd = sign*dsign*(dual.map { |i| brow[i].name.to_m('dform') }.inject(:^))
            hdv = sign*dsign*(dual.map { |i| brow[i].name.to_m('vector') }.inject(:^))
          end

          @@hodge_map[dform] = hdd
          @@hodge_map[vect] = hdv
        end
      end

      # Calculate the musical isomorphisms. Hash up the mappings both ways.
      v = brow.map { |bb| bb.name.to_m('vector') }
      d = brow.map { |bb| bb.name.to_m('dform') }

      flat = (g*Sy::Matrix.new(d).transpose).evaluate.normalize.col(0)
      sharp = (g.inverse*Sy::Matrix.new(v).transpose).evaluate.normalize.col(0)

      @@flat_map = (0..dim - 1).map { |i| [v[i], flat[i]] }.to_h
      @@sharp_map = (0..dim - 1).map { |i| [d[i], sharp[i]] }.to_h
    end

    # Return the hodge dual of an expression consisting only of basis vectors or basis
    # dforms
    def self.hodge_dual(exp)
      if !@@hodge_map.key?(exp)
        raise 'No hodge dual for ' + exp.to_s
      end

      return @@hodge_map[exp]
    end
    
    attr_reader :name
    attr_reader :type
  
    def initialize(name, t = 'real')
      @name = name
      @type = t.to_t
    end

    def hash()
      return @name.to_s.hash
    end

    def ==(other)
      return false if self.class.name != other.class.name
      return false if @type != other.type
      return @name.to_s == other.name.to_s
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
          return 1
       elsif bv1 and !bv2
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
    def is_diff?()
      return @type.is_dform?
    end

    # Returns variable which differential is based on
    # TODO: Check name collision with constant symbols (i, e, pi etc.)
    def undiff()
      return Sy::Variable.new(@name, :real)
    end
    
    def to_diff()
      return @name.to_m(:dform)
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
      if map.key?(self)
        return map[self].deep_clone
      else
        return self
      end
    end
    
    def to_s()
      if @type.is_dform?
        return Sy.setting(:diff_symbol) + @name.to_s
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
        return Sy.setting(:diff_symbol) + undiff.to_latex
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

class String
  def to_m(type = 'real')
    begin
      return Sy::ConstantSymbol.new(self)
    rescue
      return Sy::Variable.new(self, type)
    end
  end
end

class Symbol
  def to_m(type = 'real')
    begin
      return Sy::ConstantSymbol.new(self)
    rescue
      return Sy::Variable.new(self, type)
    end
  end
end
