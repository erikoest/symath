require 'spec_helper'
require 'sy'

module Sy
  describe Sy::Operation::Integration, ', simple integration' do
    x = :x.to_m
    y = :y.to_m
    dx = d(x)
    a = :a.to_m
    b = :b.to_m
    capC = :C.to_m

    exp = {
      x + 3*x**2 + 4*y + 10   => x**3 + x**2/2 + 4*x*y + 10*x + capC,
      y/x                     => y*ln(abs(x)) + capC,
      pi/x**e                 => capC + pi*x**(- e + 1)/(- e + 1),
      30*y*a**(2*b*x)         => 15*a**(2*b*x)*y/(b*ln(a)) + capC,
      12*sin(x)*cos(x)        => 6*sin(x)**2 + capC,
      12*b*cos(x)*sin(x)      => 6*b*sin(x)**2 + capC,
      (1 + x**2)**-1          => arctan(x) + capC,
      1/(1 + x**2)            => arctan(x) + capC,
      1/x**2                  => -1/x + capC,
      (1 - x**2)**(-1.to_m/2) => arcsin(x) + capC,
      sin(x)                  => -cos(x) + capC,
      sin(2*x + 3)            => -cos(2*x + 3)/2 + capC,
      e**(-a*x + b*x)         => e**(b*x - a*x)/(b - a) + capC,
    }

    exp.each do |from, to|
      it "integrates '#{from.to_s}' into '#{to.to_s}'" do
        expect(int(lmd(from, x).(x)).evaluate.normalize).to be_equal_to to
      end
    end

    bound = {
      int(3*x**3 - x, 2, 4)         => 174,
      int(3*cos(x)*sin(x), 0, pi/2) => 3.to_m/2,
    }

    bound.each do |from, to|
      it "integrates '#{from.to_s}' into '#{to.to_s}'" do
        expect(from.evaluate.evaluate.normalize).to be_equal_to to
      end
    end

    fails = [
      sin(x)*tan(x),
      x*dx,
      sin(2*x*dx),
      sin(sin(x)),
      sin(x**2),
      x**sin(x),
    ]

    fails.each do |f|
        it "fails to integrate '#{f.to_s}'" do
          expect { int(lmd(f, x).(x)).evaluate }.to raise_error("Cannot find an antiderivative for expression #{f.to_s}")
        end
    end

    it "raises error on int(x/2, dx, 0)" do
      expect { int(x/2, 0) }.to raise_error(RuntimeError, 'A cannot be defined without b and vica versa.')
      expect { op(:int, x/2, nil, 0) }.to raise_error(RuntimeError, 'A cannot be defined without b and vica versa.')
    end

    it "raises error on bounds(x**2, 2, 0, 1)" do
      expect { bounds(x**2, 2, 0, 1) }.to raise_error(RuntimeError, 'Expected variable for var, got Sy::Definition::Number')
    end

    it "raises error on bounds(x**2, dx, 0, 1)" do
      expect { bounds(x**2, dx, 0, 1) }.to raise_error(RuntimeError, 'Expected var to be a scalar, got dx')
    end
  end
end
