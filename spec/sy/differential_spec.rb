require 'spec_helper'
require 'sy'

module Sy
  n = Sy::Normalization.new

  describe Sy::Differential, ', simple polynomials' do
    poly = {
      op(:diff, :x.to_m + 3.to_m*:x.to_m**2 + 4.to_m*:y + 10.to_m)                   => 'dx + 6*dx*x',
      op(:diff, 3.to_m*:x + 2.to_m*:y.to_m**3 + 5.to_m*:z.to_m**4, :x.to_m, :y.to_m) => '3*dx + 6*dy*y^2',
    }

    poly.each do |from, to|
      it "differentiates '#{from.to_s}' into '#{to}'" do
        n.act(from.act).to_s.should == to
      end
    end
  end

  describe Sy::Differential, ', exponential functions' do
    exp = {
      op(:diff, fn('exp', :x.to_m**2)) => '2*dx*x*exp(x^2)',
      op(:diff, fn('ln', 3.to_m*:x + :x.to_m**2)) => '(3*dx + 2*dx*x)/(3*x + x^2)'
    }

    exp.each do |from, to|
      it "differentiates '#{from.to_s}' into '#{to}'" do
        n.act(from.act).to_s.should == to
      end
    end
  end
end
