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
      op(:int, x + 3*x**2 + 4*y + 10, dx) => 4*(x*y) + x**2/2 + x**3 + capC + 10*x,
      op(:int, y/x, dx)                   => fn(:ln, fn(:abs, x))*y + capC,
      op(:int, pi/x**e, dx)               => x**(1 - e)*pi/(1 - e) + capC,
      op(:int, 30*y*a**(2*b*x), dx)       => 15*(a**(2*b*x)*y/(fn(:ln, a)*b)) + capC,
    }

    poly.each do |from, to|
      it "integrates '#{from.to_s}' into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end
  end
end
