require 'spec_helper'
require 'sy'

module Sy
  describe Sy::Operation::Integration, ', simple integration' do
    x = :x
    y = :y
    dx = :x.to_m('dform')
    e = :e
    pi = :pi
    a = :a
    b = :b
    capC = :C

    poly = {
      op(:int, x + 3*x**2 + 4*y + 10, dx) => x**3 + x**2/2 + 4*x*y + 10*x + capC,
      op(:int, y/x, dx)                   => y*fn(:ln, fn(:abs, x)) + capC,
      op(:int, pi/x**e, dx)               => capC + pi*x**(- e + 1)/(- e + 1),
      op(:int, 30*y*a**(2*b*x), dx)       => 15*a**(2*b*x)*y/(b*fn(:ln, a)) + capC,
      op(:int, 12*fn(:sin, x)*fn(:cos, x), dx)   => 6*fn(:sin, x)**2 + capC,
      op(:int, 12*b*fn(:cos, x)*fn(:sin, x), dx) => 6*b*fn(:sin, x)**2 + capC,
      op(:int, (1 + x**2)**-1, dx)               => fn(:arctan, x) + capC,
      op(:int, (1 - x**2)**(-1.to_m/2), dx)      => fn(:arcsin, x) + capC,
    }

    poly.each do |from, to|
      it "integrates '#{from.to_s}' into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end

    bound = {
      op(:int, 3*x**3 - x, dx, 2, 4) => 174,
      op(:int, 3*fn(:cos, x)*fn(:sin, x), dx, 0, :pi.to_m/2) => 3.to_m/2,
    }

    bound.each do |from, to|
      it "integrates '#{from.to_s}' into '#{to.to_s}'" do
        expect(from.evaluate.evaluate.normalize).to be_equal_to to
      end
    end

    it "raises error on int(x/2, 2.to_m)" do
      expect { op(:int, x/2, 2.to_m) }.to raise_error(RuntimeError, 'Expected variable for var, got Sy::Number')
    end

    it "raises error on int(x/2, x)" do
      expect { op(:int, x/2, x) }.to raise_error(RuntimeError, 'Expected var to be a differential, got x')
    end

    it "raises error on int(x/2, dx, 0)" do
      expect { op(:int, x/2, dx, 0) }.to raise_error(RuntimeError, 'A cannot be defined without b and vica versa.')
      expect { op(:int, x/2, dx, nil, 0) }.to raise_error(RuntimeError, 'A cannot be defined without b and vica versa.')
    end

    it "raises error on bounds(x**2, 2, 0, 1)" do
      expect { op(:bounds, x**2, 2, 0, 1) }.to raise_error(RuntimeError, 'Expected variable for var, got Sy::Number')
    end

    it "raises error on bounds(x**2, dx, 0, 1)" do
      expect { op(:bounds, x**2, dx, 0, 1) }.to raise_error(RuntimeError, 'Expected var to be a scalar, got dx')
    end
  end
end
