require 'spec_helper'
require 'sy'

module Sy
  x = :x
  dx = :x.to_m('dform')
  y = :y
  dy = :y.to_m('dform')
  z = :z
  
  describe Sy::Operation::Differential, ', simple polynomials' do
    poly = {
      op(:diff, 3*x**2)                      => 6*x*dx,
      op(:diff, x + 3*x**2 + 4*y + 10)       => (6*x + 1)*dx,
      op(:diff, 3*x + 2*y**3 + 5*z**4, x, y) => 6*y**2*dy + 3*dx,
    }

    poly.each do |from, to|
      it "differentiates '#{from.to_s}' into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end
  end

  describe Sy::Operation::Differential, ', exponential functions' do
    exp = {
      op(:diff, fn('exp', x**2))       => 2*x*fn(:exp, x**2)*dx,
      op(:diff, fn('ln', 3*x + x**2))  => (2*x + 3)/(x**2 + 3*x)*dx,
    }

    exp.each do |from, to|
      it "differentiates '#{from.to_s}' into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end
  end
end
