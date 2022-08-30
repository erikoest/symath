require 'symath/definition'
require 'set'

module SyMath
  class Definition::Constant < Definition
    @@ltx_symbol = {
      :pi  => '\pi',
      :e   => '\mathrm{e}',
      :phi => '\varphi',
      :nan => '\mathrm{NaN}',
      :oo  => '\infty',
    };

    @@descriptions = {
      :pi  => 'ratio of cirle cirumference/diameter (3.14159265...)',
      :e   => "euler's number (2.71828182...)",
      :phi => 'golden ratio (1.61803398...)',
      :nan => "'not a number', i.e. an invalid value",
      :oo  => 'positive infinity',
      :i   => 'imaginary unit, first basic quaternion',
      :j   => 'second basic quaternion',
      :k   => 'third basic quaternion',
    }

    @@unit_quaternions = [:i, :j, :k].to_set

    @@builtin_constants = {
      :pi => 'real',
      :e  => 'real',
      :phi => 'real',
      :nan => 'nonfinite',
      :oo  => 'nonfinite',
      :i   => 'imaginary',
      :j   => 'quaternion',
      :k   => 'quaternion',
    }

    def self.default_type_for_constant(c)
      return @@builtin_constants[c]
    end

    def self.init_builtin()
      # Define the builtin constants
      @@builtin_constants.each do |k, v|
        self.new(k, v)
      end
    end

    def self.constants()
      return self.definitions.grep(SyMath::Definition::Constant)
    end

    @@product_reductions = {}

    def self.initialize()
      # Product reduction rules for various constants

      @@product_reductions = {
        # Imaginary and quaternion units
        :i.to_m => {
          :i.to_m => -1.to_m,
          :j.to_m => :k.to_m,
          :k.to_m => -:j.to_m,
        },
        :j.to_m => {
          :i.to_m => -:k.to_m,
          :j.to_m => -1.to_m,
          :k.to_m => :i.to_m,
        },
        :k.to_m => {
          :i.to_m => :j.to_m,
          :j.to_m => -:i.to_m,
          :k.to_m => -1.to_m,
        },
      }
    end

    def initialize(name, t = 'real')
      super(name, type: t)
    end

    def description()
      return "#{@name} - #{@@descriptions[@name]}"
    end

    def is_nan?()
      return @name == :nan
    end

    def is_finite?()
      return (@name != :oo and @name != :nan)
    end

    def is_positive?()
      return (!is_zero? and !is_nan?)
    end
    
    def is_zero?()
      return false
    end

    def conjugate()
      if self == :i
        return -:i
      else
        return self
      end
    end

    def is_unit_quaternion?()
      return @@unit_quaternions.member?(@name)
    end

    def product_reductions()
      if @@product_reductions.has_key?(self)
        return @@product_reductions[self]
      else
        return
      end
    end

    def reduce_power_modulo_sign(e)
      if self == :e
        fn = fn(:exp, e)
        # FIXME: Merge functions reduce and reduce_modulo_sign
        red = fn.reduce
        if red != fn
          return red, 1, true
        end
      end

      # Power of unit quaternions
      if is_unit_quaternion?
        # q**n for some unit quaternion
        # Exponent is 1 or not a number
        if !e.is_number? or e == 1
          return self, 1, false
        end

        # e is on the form q**n for some integer n >= 2
        x = e.value

        if x.odd?
          ret = base
          x -= 1
        else
          ret = 1.to_m
        end

        if (x/2).odd?
          return ret, -1, true
        else
          return ret, 1, true
        end
      end

      return self, 0, false
    end

    def to_latex()
      if @@ltx_symbol.key?(@name)
        return @@ltx_symbol[@name]
      else
        return @name.to_s
      end
    end
  end
end
