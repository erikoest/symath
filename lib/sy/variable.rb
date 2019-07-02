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

    # Normalize a list of vectors, and combine them into a wedge product
    def self.normalize_vectors(vectors)
      # Empty list of vectors. Return 1
      if vectors.length == 0
        return 1.to_m
      end

      # Hash up indexes of original vector order
      vhash = {}
      vectors = vectors.each_with_index do |v, i|
        # Double occurence of a vector gives zero result
        if vhash.key?(v)
          # Double vector occurence. Return 0
          return 0.to_m
        end
        vhash[v] = i
      end

      # Sort vectors and calculate the sign of the wedge product as the parity
      # of the permutation after sorting
      sorted = vectors.sort      
      sign = permutation_parity(sorted.map { |v| vhash[v] })

      return  sign.to_m.mult(sorted.inject(:^))
    end

    attr_reader :name
    attr_reader :type
  
    def initialize(name, t)
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
        bv1 = Sy::basis_order.key?(@name)
        bv2 = Sy::basis_order.key?(other.name)
        if !bv1 and bv2
          return 1
        elsif bv1 and !bv2
          return -1
        elsif bv1 and bv2
          return Sy::basis_order[@name] <=> Sy::basis_order[other.name]
        end
      end
      
      return @name.to_s <=> other.name.to_s
    end

    def is_scalar?()
      return type.is_scalar?()
    end

    def scalar_factors()
      if @type.is_scalar?
        return [self].to_enum
      else
        return [].to_enum
      end
    end

    def vector_factors()
      if @type.is_vector? or @type.is_dform?
        return [self].to_enum
      else
        return [].to_enum
      end
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
      return Sy::Variable.new(@name, 'real')
    end
    
    def to_diff()
      return Sy::Variable.new(@name, Sy::Type.new('dform'))
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
        return :d.to_s + @name.to_s
      elsif @type.is_vector?
        return @name.to_s + '\''
      elsif @type.is_covector?
        return @name.to_s + '.'
      elsif @type.is_subtype?('tensor')
        return @name.to_s + '[' + @type.index_str + ']'
      else
        return @name.to_s
      end
    end

    def to_latex()
      if is_diff?
        return '\mathrm{d}' + undiff.to_latex
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
