require 'spec_helper'
require 'sy'

module Sy
  n = Sy::Operation::Normalization.new

  describe Sy::Operation::Integration, ', simple integration' do
    poly = {
      op(:int, :x.to_m + 3.to_m*:x.to_m**2 + 4.to_m*:y + 10.to_m, :dx.to_m) =>
        'C + 10*x + x^3 + x^2/2 + 4*x*y',
      op(:int, :y.to_m/:x, :dx.to_m) =>
        'C + y*ln(abs(x))',
      op(:int, :pi.to_m/:x.to_m**:e, :dx.to_m) =>
        'C + pi*x^(1 - e)/(1 - e)',
      op(:int, 30.to_m*:y*:a.to_m**(2.to_m*:b*:x), :dx.to_m) =>
        'C + 15*y*a^(2*b*x)/(b*ln(a))',
    }

    poly.each do |from, to|
      it "integrates '#{from.to_s}' into '#{to}'" do
        n.act(from.evaluate).to_s.should == to
      end
    end
  end
end
