module SyMath
  # Abstract base class for polynomial classes
  class Poly
    attr_reader :arr, :p, :var

    # Transform polynomial back to expression form
    def to_m()
      if zero?
        return 0.to_m
      end

      exp = 0.to_m
      d = degree

      (0..d).each do |i|
        next if @arr[i] == 0
        
        if d - i == 1
          a = @var
        elsif d - i == 0
          a = 1.to_m
        else
          a = @var**(d - i)
        end

        exp += @arr[i].to_m*a
      end

      return exp
    end
      
    def strip!()
      i = @arr.index { |e| e != 0 }
      if i.nil?
        @arr = []
      else
        @arr = @arr[i..-1]
      end
      
      return self
    end

    def zero?()
      return @arr.empty?
    end

    # Return the degree of the highest power of the polynomial.
    def degree()
      # Hack: Degree of 0 should really be negative infinity
      return -1 if zero?
      return @arr.size - 1
    end

    def sort_factors(list)
      return list.sort do |a, b|
        [a.degree, a.arr] <=> [b.degree, b.arr]
      end
    end

    def sort_factors_multiple(list)
      return list.sort do |a, b|
        [a[0].degree, a[1], a[0].arr] <=> [b[0].degree, b[1], b[0].arr]
      end
    end

    def +(other)
      if other.is_a?(self.class)
        return add(other)
      elsif other.is_a?(Integer)
        return add_ground(other)
      else
        raise 'Cannot add ' + other.to_s
      end
    end

    def -(other)
      if other.is_a?(self.class)
        return sub(other)
      elsif other.is_a?(Integer)
        return sub_ground(other)
      else
        raise 'Cannot subtract ' + other.to_s
      end
    end

    def -@()
      return neg
    end

    def *(other)
      if other.is_a?(self.class)
        return mul(other)
      elsif other.is_a?(Integer)
        return mul_ground(other)
      else
        raise 'Cannot multiply with ' + other.to_s
      end
    end

    def /(other)
      if other.is_a?(self.class)
        return quo(other)
      elsif other.is_a?(Integer)
        return quo_ground(other)
      else
        raise 'Cannot divide by ' + other.to_s
      end
    end    
    
    def %(other)
      if other.is_a?(self.class)
        return rem(other)
      elsif other.is_a?(Integer)
        return trunc(other)
      else
        raise 'Cannot divide modulo ' + other.to_s
      end
    end

    def **(other)
      if other.is_a?(Integer) and other == 2
        return sqr
      else
        raise 'Cannot raise to the power of ' + other.to_s
      end
    end
    
    def [](i)
      return arr[i]
    end

    def ==(other)
      return (self.class == other.class and @arr == other.arr)
    end  
    
    # Returns leading coefficient (i.e coefficient of the biggest power)
    def lc()
      return 0 if zero?
      return @arr[0]
    end
  end
end
