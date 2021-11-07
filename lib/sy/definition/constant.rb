require 'sy/definition'
require 'set'

module Sy
  class Definition::Constant < Definition
    @@ltx_symbol = {
      :pi  => '\pi',
      :e   => '\mathrm{e}',
      :phi => '\varphi',
      :nan => '\mathrm{NaN}',
      :oo  => '\infty',
    };

    @@unit_quaternions = [:i, :j, :k].to_set

    def self.init_builtin()
      # Define the builtin constants
      self.new(:pi)
      self.new(:e)
      self.new(:phi)
      self.new(:nan)
      self.new(:oo)
      self.new(:i)
      self.new(:j)
      self.new(:k)
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

    def type()
      n = @name
      if n == :e or n == :pi or n == :phi
        return 'real'.to_t
      elsif n == :i
        return 'imaginary'.to_t
      elsif is_unit_quaternion?
        return 'quaternion'.to_t
      else
        return 'nonfinite'.to_t
      end
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
