require 'symath/vectorspace'

module SyMath
  class VectorSpace::QuantumLogic < VectorSpace
    def self.initialize()
      SyMath::VectorSpace::QuantumLogic.new
    end

    @@matrix_form = {}

    @@product_reductions = {}

    def self.initialize()
      # Create one built-in instance of this vector space
      d = SyMath.get_vector_space
      ql = self.new
      SyMath.set_default_vector_space(ql)

      # Quantum logic vectors, (one)forms and operators
      @@product_reductions = {
        :q0.to_m('form') => {
          :q1.to_m('vector')     => 0.to_m,
          :qminus.to_m('vector') => 1.to_m/fn(:sqrt, 2),
          :qplus.to_m('vector')  => 1.to_m/fn(:sqrt, 2),
          :qleft.to_m('vector')  => 1.to_m/fn(:sqrt, 2),
          :qright.to_m('vector') => 1.to_m/fn(:sqrt, 2),
          :qX.to_m('linop')      => :q1.to_m('vector'),
          :qY.to_m('linop')      => -:i*:q1.to_m('form'),
          :qZ.to_m('linop')      => :q0.to_m('form'),
          :qH.to_m('linop')      => :qplus.to_m('form'),
          :qS.to_m('linop')      => :q0.to_m('form'),
        },
        :q1.to_m('form') => {
          :q0.to_m('vector')     => 0.to_m,
          :qminus.to_m('vector') => -1.to_m/fn(:sqrt, 2),
          :qplus.to_m('vector')  => 1.to_m/fn(:sqrt, 2),
          :qleft.to_m('vector')  => -:i.to_m/fn(:sqrt, 2),
          :qright.to_m('vector') => :i.to_m/fn(:sqrt, 2),
          :qX.to_m('linop')      => :q0.to_m('form'),
          :qY.to_m('linop')      => :i*:q0.to_m('form'),
          :qZ.to_m('linop')      => -:q1.to_m('form'),
          :qH.to_m('linop')      => :qminus.to_m('form'),
          :qS.to_m('linop')      => :i*:q1.to_m('form'),
        },
        :qminus.to_m('form') => {
          :q0.to_m('vector')     => 1.to_m/fn(:sqrt, 2),
          :q1.to_m('vector')     => -1.to_m/fn(:sqrt, 2),
          :qplus.to_m('vector')  => 0.to_m,
          :qleft.to_m('vector')  => (1.to_m + :i)/2,
          :qright.to_m('vector') => (1.to_m - :i)/2,
          :qX.to_m('linop')      => -:qminus.to_m('form'),
          :qY.to_m('linop')      => -:i*:qplus.to_m('form'),
          :qZ.to_m('linop')      => :qplus.to_m('form'),
          :qH.to_m('linop')      => :q1.to_m('form'),
          :qS.to_m('linop')      => :qright.to_m('form'),
        },
        :qplus.to_m('form')  => {
          :q0.to_m('vector')     => 1.to_m/fn(:sqrt, 2),
          :q1.to_m('vector')     => 1.to_m/fn(:sqrt, 2),
          :qminus.to_m('vector') => 0.to_m,
          :qleft.to_m('vector')  => (1.to_m - :i)/2,
          :qright.to_m('vector') => (1.to_m + :i)/2,
          :qX.to_m('linop')      => :qplus.to_m('form'),
          :qY.to_m('linop')      => :i*:qminus.to_m('form'),
          :qZ.to_m('linop')      => :qminus.to_m('form'),
          :qH.to_m('linop')      => :q0.to_m('form'),
          :qS.to_m('linop')      => :qleft.to_m('form'),
        },
        :qleft.to_m('form')  => {
          :q0.to_m('vector')     => 1.to_m/fn(:sqrt, 2),
          :q1.to_m('vector')     => :i.to_m/fn(:sqrt, 2),
          :qminus.to_m('vector') => (1.to_m - :i)/2,
          :qplus.to_m('vector')  => (1.to_m + :i)/2,
          :qright.to_m('vector') => 0.to_m,
          :qX.to_m('linop')      => :qplus.to_m('form'),
          :qY.to_m('linop')      => :i*:qminus.to_m('form'),
          :qZ.to_m('linop')      => :qminus.to_m('form'),
          :qH.to_m('linop')      => :q0.to_m('form'),
          :qS.to_m('linop')      => :qminus.to_m('form'),
        },
        :qright.to_m('form')  => {
          :q0.to_m('vector')     => 1.to_m/fn(:sqrt, 2),
          :q1.to_m('vector')     => -:i.to_m/fn(:sqrt, 2),
          :qminus.to_m('vector') => (1.to_m + :i)/2,
          :qplus.to_m('vector')  => (1.to_m - :i)/2,
          :qleft.to_m('vector')  => 0.to_m,
          :qX.to_m('linop')      => :qplus.to_m('form'),
          :qY.to_m('linop')      => :i*:qminus.to_m('form'),
          :qZ.to_m('linop')      => :qminus.to_m('form'),
          :qH.to_m('linop')      => :q0.to_m('form'),
          :qS.to_m('linop')      => :qplus.to_m('form'),
        },
      }

      @@matrix_form = {
        :qplus  => 1/fn(:sqrt, 2)*[1, 1].to_m.transpose,
        :qminus => 1/fn(:sqrt, 2)*[1, -1].to_m.transpose,
        :qright => 1/fn(:sqrt, 2)*[1, :i].to_m.transpose,
        :qleft  => 1/fn(:sqrt, 2)*[1, -:i].to_m.transpose,
      }

      SyMath.set_default_vector_space(d)
    end

    def initialize(name = 'quantum_logic')
      super(name, dimension: 2, basis: [:q0, :q1].to_m, normalized: true)
    end

    def product_reductions_by_variable(left)
      if @@product_reductions.has_key?(left)
        return @@product_reductions[left]
      else
        return
      end
    end

    def variable_to_matrix(var)
      if @@matrix_form.has_key?(var.name)
        m = @@matrix_form[var.name]

        if var.type.is_form?
          return m.conjugate_transpose
        else
          return m
        end
      end

      return super(var)
    end
  end
end
