require 'spec_helper'
require 'sy'

module Sy
  x = :x
  y = :y
  z = :z
  dx = :x.to_m('dform')
  dy = :y.to_m('dform')
  dz = :z.to_m('dform')
  
  describe Sy::Operation::Differential, ', error conditions' do
    it 'raises error on diff(x, dx)' do
      expect { diff(x, dx) }.to raise_error('Var is not allowed to be differential, got dx')
    end
    it 'raises error on diff(x, pi)' do
      expect { diff(x, pi) }.to raise_error('Expected variable, got Sy::ConstantSymbol')
    end
  end

  describe Sy::Operation::Differential, ', simple polynomials' do
    poly = {
      diff(3*x**2)                      => 6*x*dx,
      diff(x + 3*x**2 + 4*y + 10)       => 6*x*dx + dx,
      diff(3*x + 2*y**3 + 5*z**4, x, y) => 6*y**2*dy + 3*dx,
      diff(3*x*z*(dx^dy) + 2*z*dz, z)   => (((3*x)*dx)^dy)^dz,
      diff(3/x, x)                      => -3/x**2*dx,
    }

    poly.each do |from, to|
      it "differentiates '#{from.to_s}' into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end
  end

  describe Sy::Operation::Differential, ', exponential functions' do
    exp = {
      diff(exp(x**2))       => 2*x*exp(x**2)*dx,
      diff(ln(3*x + x**2))  => (2*x*dx + 3*dx)/(x**2 + 3*x),
    }

    exp.each do |from, to|
      it "differentiates '#{from.to_s}' into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end
  end

  describe Sy::Operation::Differential, ', errors' do
    it "raises error on diff(op1, x), op1 is a defined operator" do
      expect { diff(op(:op1, x), x).evaluate }.to raise_error('Cannot calculate differential of expression op1(x)')
    end

    it "raises error on diff(fn1, x), fn1 is a defined function" do
      expect { diff(fn(:fn1, x), x).evaluate }.to raise_error('Cannot calculate differential of expression fn1(x)')
    end
  end
end
