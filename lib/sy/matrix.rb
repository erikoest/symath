require 'sy/value'

module Sy
  # TODO: Should the matrix rather be designed as an operator?
  class Matrix < Value
    attr_reader :nrows, :ncols
    
    def initialize(data)
      raise 'Not an array: ' + data.to_s if !data.is_a?(Array)
      raise 'Array is empty' if data.length == 0

      if data[0].is_a?(Array) then
        # Multidimensional array
        @nrows = data.length
        raise 'Number of columns is zero' if data[0].length == 0
        @ncols = data[0].length
        # Check that all rows contain arrays of the same length
        data.each do |r|
          raise 'Row is not array' if !r.is_a?(Array)
          raise 'Row has invalid length' if r.length != @ncols
        end
        @elements = data.map { |r| r.map { |c| c.to_m } }
      else
        # Simple array. Creates a single row matrix
        @nrows = 1
        @ncols = data.length
        @elements = [data.map { |c| c.to_m }]
      end
    end

    def hash()
    end
    
    def row(i)
      return elements[i]
    end

    def col(i)
      return elements.map { |r| r[i] }
    end

    def [](i, j)
      return elements[i][j]
    end

    def ==(other)
      return false if nrows != other.nrows
      return false if ncols != other.ncols
      
      for i in @nrows do
        for j in @ncols do
          return false if self[i, j] != other[i, j]
        end
      end

      return true
    end

    def to_s()
      # This will in many cases look rather messy, but we don't have the option
      # to format the matrix over multiple lines.
      return '[' + @elements.map { |r| r.map { |c| c.to_s }.join(', ') }.join('; ') + ']'
    end
  end
end

class Array
  def to_m()
    return Sy::Matrix.new(self)
  end
end
