require 'sy/operation'

# Support for multivariate polynomials
# Support fraction coefficients

module Sy
  class Operation::Factorization < Operation
    # Factorization of univariate polynomials. The Zassenhaus algorithm is
    # used for the factorization, given a square free polynomial. Yun's
    # algorithm is used for decomposing a polynomial into square free
    # components.
    def description
      return 'Factorize a univariable polynomial'
    end

    def act(exp)
      dup = Sy::Poly::DUP.new(exp)
      factors = dup.factor
      
      ret = factors[1].map do |f|
        if f[1] != 1
          f[0].to_m**f[1]
        else
          f[0].to_m
        end
      end

      if factors[0] != 1
        ret.unshift(factors[0].to_m)
      end

      return ret.inject(:*)
    end
  end
end
