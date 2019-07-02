require 'spec_helper'
require 'sy'

module Sy
  n = Sy::Operation::Normalization.new

  describe Sy::Operation::Integration, ', simple integration' do
    dx = :x.to_m('dform')

    poly = {
      op(:int, :x.to_m + 3.to_m*:x.to_m**2 + 4.to_m*:y + 10.to_m, dx) =>
        '4*x*y + x**2/2 + x**3 + C + 10*x',
      op(:int, :y.to_m/:x, dx) =>
        'ln(abs(x))*y + C',
      op(:int, :pi.to_m/:x.to_m**:e, dx) =>
        'x**(1 - e)*pi/(1 - e) + C',
      op(:int, 30.to_m*:y*:a.to_m**(2.to_m*:b*:x), dx) =>
        '15*a**(2*b*x)*y/(ln(a)*b) + C',
    }

    poly.each do |from, to|
      it "integrates '#{from.to_s}' into '#{to}'" do
        n.act(from.evaluate).to_s.should == to
      end
    end
  end
end
