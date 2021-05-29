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
    }

    poly.each do |from, to|
      it "integrates '#{from.to_s}' into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end
  end
end
