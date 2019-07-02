require 'spec_helper'
require 'sy'

module Sy
  n = Sy::Operation::Normalization.new

  describe Sy::Operation::Differential, ', simple polynomials' do
    poly = {
      op(:diff, 3.to_m*:x.to_m**2) =>
          '6*x*dx',
      op(:diff, :x.to_m + 3.to_m*:x.to_m**2 + 4.to_m*:y + 10.to_m) =>
          '(6*x + 1)*dx',
      op(:diff, 3.to_m*:x + 2.to_m*:y.to_m**3 + 5.to_m*:z.to_m**4, :x.to_m, :y.to_m) =>
          '3*dx + 6*y**2*dy',
    }

    poly.each do |from, to|
      it "differentiates '#{from.to_s}' into '#{to}'" do
        n.act(from.evaluate).to_s.should == to
      end
    end
  end

  describe Sy::Operation::Differential, ', exponential functions' do
    exp = {
      op(:diff, fn('exp', :x.to_m**2))            => '2*exp(x**2)*x*dx',
      op(:diff, fn('ln', 3.to_m*:x + :x.to_m**2)) => '(2*x/(x**2 + 3*x) + 3/(x**2 + 3*x))*dx'
    }

    exp.each do |from, to|
      it "differentiates '#{from.to_s}' into '#{to}'" do
        n.act(from.evaluate).to_s.should == to
      end
    end
  end
end
