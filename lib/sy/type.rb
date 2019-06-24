module Sy
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
      # Scalar types
      'scalar' => {
        'complex' => {
          'real' => {
            'rational' => {
              'integer' => {
                'natural' => 1
              }
            }
          },
          'imaginary' => 1,
        },
      },
      # Vector types (one dimension param)
      'tensor' => {
        'nvector' => {
          'vector' => 1,
        },
        'nform' => {
          'covector' => {
            'dform' => 1,
          }
        },
      },
      # Matrices
      'matrix' => {
        'column' => 1,
        'row' => 1,
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

    def initialize(name, dimn: nil, dimm: nil, indexes: nil)
      @name = name
      @dimn = dimn
      @dimm = dimm
      @indexes = indexes
    end

    # Check if a type is a subtype of another
    def is_subtype?(other)
      # Allow input as type or as string
      other = other.to_t

      # Types are not compatible if they have different attributes.
      # FIXME: What is the correct way to define subtypes of matrices and tensors
      # with respect to dimensions and indexes?
      return false if @dim1 != other.dimn
      return false if @dim2 != other.dimm
      return false if @indexes != other.indexes

      # Same types, 
      return true if @name == other.name

      # This is a subtype of other
      return true if @@subtype[@name].key?(other.name)

      # Fallback to false
      return false
    end

    def common_parent(other)
      if other.is_subtype?(self)
        return self
      elsif is_subtype?(other)
        return other
      elsif is_subtype?(@@types['complex']) and other.is_subtype?(@@types['complex'])
        return  @@types['complex']
      else
        raise 'No common type for ' + to_s + ' and ' + other.to_s
      end
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

    # True if type is a pseudovector (relative to given default vector room)
    def is_pseudovector?()
      return false
    end

    # True if type is a pseudoscalar (relative to given default vector room)
    def is_pseudoscalar?()
      return false
    end
    
    # True if type is the dual of an nvector
    def is_nform?()
      return is_subtype?('nform')
    end

    def is_covector?()
      return is_subtype?('covector')
    end

    def is_dform?()
      return is_subtype?('dform')
    end
    
    # Return index list as a string coded with upper indices as ' and lower indices as .
    def index_str()
      return @indexes.map do |i|
        if i == 'u'
          ''''
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
        return @name + '[' + @dimm + 'x' + @dimm + ']'
      elsif !@indexes.nil
        return @name + '[' + @indexes.join('') + ']'
      else
        return @name
      end
    end

    # Hash of simple types, for faster instansiations.
    @@types = {
      'natural'   => Sy::Type.new('natural'),
      'integer'   => Sy::Type.new('integer'),
      'rational'  => Sy::Type.new('rational'),
      'real'      => Sy::Type.new('real'),
      'complex'   => Sy::Type.new('complex'),
      'imaginary' => Sy::Type.new('imaginary'),
      'vector'    => Sy::Type.new('vector', indexes: ['u']),
      'covector'  => Sy::Type.new('covector', indexes: ['l']),
      'dform'     => Sy::Type.new('dform', indexes: ['l']),
    }

    def self.types
      return @@types
    end

    def to_t(*args)
      return self
    end
  end
end

class String
  def to_t(*args)
    if args.nil? and !Sy::Type.types.key?(self)
      return Sy::Type.types[self]
    end

    return Sy::Type.new(self, *args)
  end
end

class Symbol
  def to_t(*args)
    if args.nil? and !Sy::Type.types.key?(self)
      return Sy::Type.types[self]
    end

    return Sy::Type.new(self, *args)
  end
end
