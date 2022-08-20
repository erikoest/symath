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
      :qpluss => 'qubit value |+>',
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
      :qpluss => 'vector',
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
      self.new(:qpluss, 'covector')
    end

    def self.constants()
      return self.definitions.grep(SyMath::Definition::Constant)
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

    def calc_unit_quaternions(q)
      # Calculation map for unit quaternions
      qmap = {
        :i => {
          :i => -1.to_m,
          :j => :k.to_m,
          :k => -:j.to_m,
        },
        :j => {
          :i => -:k.to_m,
          :j => -1.to_m,
          :k => :i.to_m,
        },
        :k => {
          :i => :j.to_m,
          :j => -:i.to_m,
          :k => -1.to_m,
        },
      }
    
      return qmap[@name][q.name]
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
