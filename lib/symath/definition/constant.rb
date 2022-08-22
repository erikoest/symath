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
      :q0  => 'qubit value |0>',
      :q1  => 'qubit value |1>',
      :qminus => 'qubit value |->',
      :qplus  => 'qubit value |+>',
      :qright => 'qubit value |right>',
      :qleft  => 'qubit value |left>',
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
      :q0  => 'vector',
      :q1  => 'vector',
      :qminus => 'vector',
      :qplus  => 'vector',
      :qright => 'vector',
      :qleft  => 'vector',
    }

    def self.default_type_for_constant(c)
      return @@builtin_constants[c]
    end

    def self.init_builtin()
      # Define the builtin constants
      @@builtin_constants.each do |k, v|
        self.new(k, v)
      end

      self.new(:q0, 'covector')
      self.new(:q1, 'covector')
      self.new(:qminus, 'covector')
      self.new(:qplus,  'covector')
      self.new(:qright, 'covector')
      self.new(:qleft,  'covector')
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
        # Quantum logic vectors, covectors and operators
        :q0.to_m('covector') => {
          :q1.to_m('vector')     => 0.to_m,
          :qminus.to_m('vector') => 1.to_m/fn(:sqrt, 2),
          :qplus.to_m('vector')  => 1.to_m/fn(:sqrt, 2),
          :qleft.to_m('vector')  => 1.to_m/fn(:sqrt, 2),
          :qright.to_m('vector') => 1.to_m/fn(:sqrt, 2),
          :qX.to_m('linop')      => :q1.to_m('vector'),
          :qY.to_m('linop')      => -:i*:q1.to_m('covector'),
          :qZ.to_m('linop')      => :q0.to_m('covector'),
          :qH.to_m('linop')      => :qplus.to_m('covector'),
          :qS.to_m('linop')      => :q0.to_m('covector'),
        },
        :q1.to_m('covector') => {
          :q0.to_m('vector')     => 0.to_m,
          :qminus.to_m('vector') => -1.to_m/fn(:sqrt, 2),
          :qplus.to_m('vector')  => 1.to_m/fn(:sqrt, 2),
          :qleft.to_m('vector')  => -:i.to_m/fn(:sqrt, 2),
          :qright.to_m('vector') => :i.to_m/fn(:sqrt, 2),
          :qX.to_m('linop')      => :q0.to_m('covector'),
          :qY.to_m('linop')      => :i*:q0.to_m('covector'),
          :qZ.to_m('linop')      => -:q1.to_m('covector'),
          :qH.to_m('linop')      => :qminus.to_m('covector'),
          :qS.to_m('linop')      => :i*:q1.to_m('covector'),
        },
        :qminus.to_m('covector') => {
          :q0.to_m('vector')     => 1.to_m/fn(:sqrt, 2),
          :q1.to_m('vector')     => -1.to_m/fn(:sqrt, 2),
          :qplus.to_m('vector')  => 0.to_m,
          :qleft.to_m('vector')  => (1.to_m + :i)/2,
          :qright.to_m('vector') => (1.to_m - :i)/2,
          :qX.to_m('linop')      => -:qminus.to_m('covector'),
          :qY.to_m('linop')      => -:i*:qplus.to_m('covector'),
          :qZ.to_m('linop')      => :qplus.to_m('covector'),
          :qH.to_m('linop')      => :q1.to_m('covector'),
          :qS.to_m('linop')      => :qright.to_m('covector'),
        },
        :qplus.to_m('covector')  => {
          :q0.to_m('vector')     => 1.to_m/fn(:sqrt, 2),
          :q1.to_m('vector')     => 1.to_m/fn(:sqrt, 2),
          :qminus.to_m('vector') => 0.to_m,
          :qleft.to_m('vector')  => (1.to_m - :i)/2,
          :qright.to_m('vector') => (1.to_m + :i)/2,
          :qX.to_m('linop')      => :qplus.to_m('covector'),
          :qY.to_m('linop')      => :i*:qminus.to_m('covector'),
          :qZ.to_m('linop')      => :qminus.to_m('covector'),
          :qH.to_m('linop')      => :q0.to_m('covector'),
          :qS.to_m('linop')      => :qleft.to_m('covector'),
        },
        :qleft.to_m('covector')  => {
          :q0.to_m('vector')     => 1.to_m/fn(:sqrt, 2),
          :q1.to_m('vector')     => :i.to_m/fn(:sqrt, 2),
          :qminus.to_m('vector') => (1.to_m - :i)/2,
          :qplus.to_m('vector')  => (1.to_m + :i)/2,
          :qright.to_m('vector') => 0.to_m,
          :qX.to_m('linop')      => :qplus.to_m('covector'),
          :qY.to_m('linop')      => :i*:qminus.to_m('covector'),
          :qZ.to_m('linop')      => :qminus.to_m('covector'),
          :qH.to_m('linop')      => :q0.to_m('covector'),
          :qS.to_m('linop')      => :qminus.to_m('covector'),
        },
        :qright.to_m('covector')  => {
          :q0.to_m('vector')     => 1.to_m/fn(:sqrt, 2),
          :q1.to_m('vector')     => -:i.to_m/fn(:sqrt, 2),
          :qminus.to_m('vector') => (1.to_m + :i)/2,
          :qplus.to_m('vector')  => (1.to_m - :i)/2,
          :qleft.to_m('vector')  => 0.to_m,
          :qX.to_m('linop')      => :qplus.to_m('covector'),
          :qY.to_m('linop')      => :i*:qminus.to_m('covector'),
          :qZ.to_m('linop')      => :qminus.to_m('covector'),
          :qH.to_m('linop')      => :q0.to_m('covector'),
          :qS.to_m('linop')      => :qplus.to_m('covector'),
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

    def reduce_product_modulo_sign(o)
      if self.type.is_covector? and o.type.is_vector?
        # <a|a> = 1
        # FIXME: This is true only for unit vectors and covectors
        # We need a vector property: is_unitary?
        if self.name == o.name
          return 1.to_m, 1, true
        end
      end

      return super(o)
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
