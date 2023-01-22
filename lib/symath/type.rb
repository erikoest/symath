module SyMath
  class Type
    # Type name
    attr_reader :name
    # Matrix dimensions
    attr_reader :dimn, :dimm
    # Tensor indexes (array of 'h' amd 'l')
    attr_reader :indexes

    # Type hierarchy with generic types at the top level and more specific
    # types further down.
    @@hierarchy = {
      # Non numbers
      :nonfinite => 1,
      # Operators
      :operator => {
        # Function
        :function => 1,
        # Linear operators
        :linop => {
          # Matrices
          :matrix => {
            :column => 1,
            :row => 1,
          },
          # Vector types (one dimension param)
          :tensor => {
            :nvector => {
              :vector => 1,
            },
            :form => 1,
          },
          # Scalar types
          :quaternion => {
            :scalar => {
              :complex => {
                :real => {
                  :rational => {
                    :integer => {
                      :natural => 1
                    }
                  }
                },
                :imaginary => 1,
              }
            }
          }
        }
      }
    }

    # Create a transitively closed subtype hash for quicker subtype lookup
    @@subtype = {}

    def self.fill_subtype_hash(hiera, bases = [])
      hiera.keys.each do |k|
        bases.each do |b|
          if !@@subtype.key?(k)
            @@subtype[k] = {}
          end
          @@subtype[k][b] = 1
        end

        next unless hiera[k].is_a?(Hash)

        fill_subtype_hash(hiera[k], bases + [k])
      end
    end

    fill_subtype_hash(@@hierarchy)

    @@types = {}

    def self.types
      return @@types
    end

    def initialize(name, dimn: nil, dimm: nil, indexes: nil)
      @name = name.to_sym
      @dimn = dimn
      @dimm = dimm
      @indexes = indexes
    end

    # Hash of simple types, for faster instansiations.
    @@types = {
      :natural    => SyMath::Type.new(:natural),
      :integer    => SyMath::Type.new(:integer),
      :rational   => SyMath::Type.new(:rational),
      :real       => SyMath::Type.new(:real),
      :complex    => SyMath::Type.new(:complex),
      :imaginary  => SyMath::Type.new(:imaginary),
      :quaternion => SyMath::Type.new(:quaternion),
      :vector     => SyMath::Type.new(:vector, indexes: ['u']),
      :form       => SyMath::Type.new(:form, indexes: ['l']),
    }

    # Check if a type is a subtype of another
    def is_subtype?(other)
      # Allow input as type or as string
      other = other.to_t

      # Types are not compatible if they have different attributes.
      # FIXME: What is the correct way to define subtypes of matrices
      # with respect to dimensions?
      return false if @dim1 != other.dimn
      return false if @dim2 != other.dimm

      # Same types, 
      return true if @name == other.name

      # This is a subtype of other
      return true if @@subtype.key?(@name) and @@subtype[@name].key?(other.name)

      # Fallback to false
      return false
    end

    def common_parent(other)
      if other.is_subtype?(self)
        return self
      elsif is_subtype?(other)
        return other
      elsif is_subtype?(@@types[:complex]) and
           other.is_subtype?(@@types[:complex])
        return  @@types[:complex]
      else
        raise "No common type for #{self} and #{other}"
      end
    end

    # Determine the type of a sum
    def sum(other)
      if is_subtype?('quaternion') and
        other.is_subtype?('quaternion')
        return common_parent(other)
      elsif self == other
        return self
      elsif self.is_subtype?('tensor') or other.is_subtype?('tensor')
        return 'tensor'.to_t
      else
        raise "Types #{self} and #{other} cannot be summed."
      end
    end

    # Determine the type of a product
    def product(other)
      scalar = is_scalar?
      oscalar = other.is_scalar?

      # FIXME: Collect these mappings in a hash
      # Do some of these cases belong to the wedge operator?
      if scalar and oscalar
        return common_parent(other)
      elsif scalar
        return other
      elsif oscalar
        return self
      elsif is_form? and other.is_form?
        indexes = self.indexes + other.indexes
        return 'form'.to_t(indexes: indexes)
      elsif is_vector? and other.is_vector?
        # Outer product of vectors
        return 'nvector'.to_t(indexes: ['u', 'u'])
      elsif is_oneform? and other.is_vector?
        # Inner product of oneform and vector
        return 'scalar'.to_t
      elsif is_vector? and other.is_oneform?
        # Outer product of vector and oneform
        return 'linop'
      elsif is_subtype?('matrix') and other.is_subtype?('matrix')
        if dimn != other.dimm
          raise "Types #{self} and #{other} cannot be multiplied"
        end

        return 'matrix'.to_t(dimm: dimm, dimn: other.dimn)
      elsif is_oneform? and other.is_subtype?('linop')
        return 'form'.to_t
      elsif is_subtype?('linop') and other.is_vector?
        return 'vector'.to_t
      elsif is_subtype?('linop') and other.is_subtype?('linop')
        return 'linop'.to_t
      else
        raise "Types #{self} and #{other} cannot be multiplied"
      end
    end

    def wedge(other)
      if is_subtype?('tensor') and
         other.is_subtype?('tensor')
        # Wedge product of two tensor-like object. Determine index signature
        # and subtype.
        ix = indexes + other.indexes
        if (ix - ['u']).empty?
          ret = 'nvector'
        elsif (ix - ['l']).empty?
          ret = 'form'
        else
          ret = 'tensor'
        end

        return ret.to_t(indexes: ix)
      end

      if is_scalar?
        return other
      end

      if other.is_scalar?
        return self
      end

      raise "Types #{self} and #{other} cannot be wedged"
    end

    # Return tensor degree (rank)
    def degree()
      return @indexes.length
    end

    # True if type is a scalar value 
    def is_scalar?()
      return is_subtype?('scalar')
    end

    def is_vector?()
      return is_subtype?('vector')
    end

    # True if type is a linear combination of blades
    def is_nvector?()
      return is_subtype?('nvector')
    end

    def is_matrix?()
      return ([:matrix, :colum, :row].include?(@name))
    end

    # True if type is a pseudovector. We use the notion of a pseudovector
    # both for N-1 dimensional nvectors and nforms (N being the dimensionality
    # of the default vector space)
    def is_pseudovector?()
      if !is_subtype?('nvector') and !is_subtype?('form')
        return false
      end

      # FIXME: This does not depend on the default vector space
      return degree == SyMath.get_vector_space.basis.ncols - 1
    end

    # True if type is a pseudoscalar. We use the notion of a pseudoscalar
    # both for N dimensional nvectors and nforms (N being the dimensionality
    # of the default vector space)
    def is_pseudoscalar?()
      if !is_subtype?('nvector') and !is_subtype?('form')
        return false
      end

      return degree == SyMath.get_vector_space.basis.ncols
    end

    def is_form?()
      return is_subtype?('form')
    end

    def is_oneform?()
      return (is_subtype?('form') and degree == 1)
    end

    # Return index list as a string coded with upper indices as ' and lower
    # indices as .
    def index_str()
      return @indexes.map do |i|
        if i == 'u'
          '\''
        elsif i == 'l'
          '.'
        end
      end.join('')
    end
    
    def ==(other)
      return false if @dim1 != other.dimn
      return false if @dim2 != other.dimm
      return false if @indexes != other.indexes
      return @name == other.name
    end

    def to_s()
      if !@dimn.nil?
        return @name.to_s + '[' + @dimm.to_s + 'x' + @dimn.to_s + ']'
      elsif !@indexes.nil?
        return @name.to_s + '[' + @indexes.join('') + ']'
      else
        return @name.to_s
      end
    end

    def to_t(*args)
      return self
    end
  end
end

class String
  def to_t(**args)
    if args.empty? and SyMath::Type.types.key?(self.to_sym)
      return SyMath::Type.types[self.to_sym]
    end

    return SyMath::Type.new(self, **args)
  end
end

class Symbol
  def to_t(**args)
    if args.empty? and SyMath::Type.types.key?(self)
      return SyMath::Type.types[self]
    end

    return SyMath::Type.new(self, **args)
  end
end
