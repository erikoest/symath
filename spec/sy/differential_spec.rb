require 'spec_helper'
require 'sy'

module Sy
  extend Sy::Definitions
  
  x = :x
  y = :y
  z = :z
  dx = d(x)
  dy = d(y)
  dz = d(z)

  define_fn(:fn123, [:x])
  define_op(:op123, [:x])
  
  describe Sy::Operation::Differential, ', error conditions' do
    it 'raises error on d(x, dx)' do
      expect { d(x, dx) }.to raise_error('Var is not allowed to be differential, got dx')
    end
    it 'raises error on d(x, pi)' do
      expect { d(x, pi) }.to raise_error('Expected variable, got Sy::Definition::Constant')
    end
  end

  describe Sy::Operation::Differential, ', simple polynomials' do
    poly = {
      d(3*x**2)                             => lmd(6*x*dx, x),
      d(x + 3*x**2 + 4*y + 10)              => lmd(6*x*dx + dx, x),
      d(lmd(3*x + 2*y**3 + 5*z**4, :x, :y)) => lmd(6*y**2*dy + 3*dx, x, y),
      d(lmd(3*x*z*(dx^dy) + 2*z*dz, :z))    => lmd((((3*x)*dx)^dy)^dz, z),
      d(lmd(3/x, :x))                       => lmd(-3/x**2*dx, x),
    }

    poly.each do |from, to|
      it "differentiates '#{from.to_s}' into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end
  end

  describe Sy::Operation::Differential, ', exponential functions' do
    exp = {
      d(exp(x**2))       => lmd(2*x*exp(x**2)*dx, x),
      d(ln(3*x + x**2))  => lmd((2*x*dx + 3*dx)/(x**2 + 3*x), x),
    }

    exp.each do |from, to|
      it "differentiates '#{from.to_s}' into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end
  end

  describe Sy::Operation::Differential, ', errors' do
    it "raises error on d(op123, x), op123 is a defined operator" do
      expect { d(op(:op123, x), x).evaluate }.to raise_error('Cannot calculate differential of expression op123(x)')
    end

    it "raises error on d(fn123, x), fn123 is a defined function" do
      expect { d(fn(:fn123, x), x).evaluate }.to raise_error('Cannot calculate differential of expression fn123(x)')
    end
  end
end
