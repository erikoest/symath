require 'spec_helper'
require 'sy'

module Sy
  n = Sy::Operation::Normalization.new

  describe Sy::Operation::Integration, ', simple integration' do
    x = :x
    y = :y
    dx = :x.to_m('dform')
    e = :e
    pi = :pi
    a = :a
    b = :b

    poly = {
      op(:int, x + 3*x**2 + 4*y + 10, dx) => '4*x*y + x**2/2 + x**3 + C + 10*x',
      op(:int, y/x, dx)                   => 'ln(abs(x))*y + C',
      op(:int, pi/x**e, dx)               => 'x**(1 - e)*pi/(1 - e) + C',
      op(:int, 30*y*a**(2*b*x), dx)       => '15*a**(2*b*x)*y/(ln(a)*b) + C',
    }

    poly.each do |from, to|
      it "integrates '#{from.to_s}' into '#{to}'" do
        expect(n.act(from.evaluate).to_s).to be == to
      end
    end
  end
end
