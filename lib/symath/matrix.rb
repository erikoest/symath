require 'symath/value'

module SyMath
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

    # :nocov:
    def is_commutative?()
      return false
    end

    def is_associative?()
      return true
    end
    # :nocov:

    def hash()
      return [0, 0].hash
    end
    
    def row(i)
      return @elements[i]
    end

    def col(i)
      return @elements.map { |r| r[i] }
    end

    def [](i, j)
      return @elements[i][j]
    end

    def is_square?()
      return @ncols == @nrows
    end

    def matrix_mul(other)
      if !other.is_a?(SyMath::Matrix)
        data = (0..@nrows - 1).map do |r|
          (0..@ncols - 1).map { |c| self[r, c]*other }
        end

        return SyMath::Matrix.new(data)
      end
      
      raise 'Invalid dimensions' if @ncols != other.nrows

      data = (0..@nrows - 1).map do |r|
        (0..other.ncols - 1).map do |c|
          (0..@ncols - 1).map do |c2|
            self[r, c2]*other[c2, c]
          end.inject(:+) 
        end
      end

      return SyMath::Matrix.new(data)
    end

    def matrix_div(other)
      raise 'Cannot divide matrix by matrix' if other.is_a?(SyMath::Matrix)

      data = (0..@nrows - 1).map do |r|
        (0..@ncols - 1).map { |c| self[r, c]/other }
      end

      return SyMath::Matrix.new(data)
    end

    def /(other)
      return div(other)
    end

    def matrix_add(other)
      if other.is_a?(SyMath::Minus) and other.argument.is_a?(SyMath::Matrix)
        return self.matrix_sub(other.argument)
      end

      raise 'Invalid dimensions' if @ncols != other.ncols or @nrows != other.nrows

      data = (0..@nrows - 1).map do |r|
        (0..@ncols - 1).map do |c|
          self[r, c] + other[r, c]
        end
      end

      return SyMath::Matrix.new(data)
    end

    def +(other)
      return add(other)
    end

    def matrix_sub(other)
      raise 'Invalid dimensions' if @ncols != other.ncols or @nrows != other.nrows

      data = (0..@nrows - 1).map do |r|
        (0..@ncols - 1).map do |c|
          self[r, c] - other[r, c]
        end
      end

      return SyMath::Matrix.new(data)
    end

    def -(other)
      return sub(other)
    end

    def matrix_neg()
      data = @elements.map do |r|
        r.map do |e|
          - e
        end
      end

      return SyMath::Matrix.new(data)
    end

    def -@()
      return neg
    end

    def transpose()
      return SyMath::Matrix.new(@elements.transpose)
    end

    def inverse()
      raise 'Matrix is not square' if !is_square?

      return adjugate.matrix_div(determinant)
    end

    # The adjugate of a matrix is the transpose of the cofactor matrix
    def adjugate()
      data = (0..@ncols - 1).map do |c|
        (0..@nrows - 1).map { |r| cofactor(r, c) }
      end

      return SyMath::Matrix.new(data)
    end

    def determinant()
      raise 'Matrix is not square' if !is_square?
      
      return minor((0..@nrows - 1).to_a, (0..@ncols - 1).to_a)
    end

    # The minor is the determinant of a submatrix. The submatrix is given by
    # the rows and cols which are arrays of indexes to the rows and columns
    # to be included
    def minor(rows, cols)
      raise 'Not square' if rows.length != cols.length

      # Determinant of a single element is just the element
      if rows.length == 1
        return self[rows[0], cols[0]]
      end

      ret = 0.to_m
      sign = 1
      subrows = rows - [rows[0]]

      # Loop over all elements e in first row. Calculate determinant as:
      #   sum(sign*e*det(rows + cols except the one including e))
      # The sign variable alternates between 1 and -1 for each summand 
      cols.each do |c|
        subcols = cols - [c]
        if (sign > 0)
          ret += self[rows[0], c]*minor(subrows, subcols)
        else
          ret -= self[rows[0], c]*minor(subrows, subcols)
        end

        sign *= -1
      end

      return ret
    end

    # The cofactor of an element is the minor given by the rows and columns
    # not including the element, multiplied by a sign factor which alternates
    # for each row and column
    def cofactor(r, c)
      sign = (-1)**(r + c)
      rows = (0..@nrows - 1).to_a - [r]
      cols = (0..@ncols - 1).to_a - [c]
      return minor(rows, cols)*sign.to_m
    end
    
    def trace()
      raise 'Matrix is not square' if !is_square?
      
      return (0..@nrows - 1).map { |i| self[i, i] }.inject(:+)
    end
    
    def ==(other)
      return false if !other.is_a?(SyMath::Matrix)

      return false if nrows != other.nrows
      return false if ncols != other.ncols

      (0..@nrows - 1).each do |r|
        (0..@ncols - 1).each do |c|
          return false if self[r, c] != other[r, c]
        end
      end

      return true
    end

    alias eql? ==

    def to_s()
      # This will in many cases look rather messy, but we don't have the option
      # to format the matrix over multiple lines.
      return '[' + @elements.map { |r| r.map { |c| c.to_s }.join(', ') }.join('; ') + ']'
    end

    def type()
      return SyMath::Type.new('matrix', dimn: ncols, dimm: nrows)
    end
  end
end

class Array
  def to_m()
    return SyMath::Matrix.new(self)
  end
end
