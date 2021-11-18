require 'spec_helper'
require 'symath'

module SyMath
  describe SyMath::Definition::Function, ', evaluate' do
    define_fn(:f1, [:x, :y], 'y**3 + x**2 + 2')
    define_fn(:g1, [:x])

    ex_f = fn(:f1, 3, 5)

    it 'f(3, 5) evaluates to 136' do
      expect(ex_f.evaluate.normalize).to be_equal_to 136.to_m
    end

    it 'sinh(5) evaluates to (e**5 + e**-5)/2' do
      expect(sinh(5).evaluate).to be_equal_to (e**5 - e**-5)/2
    end

    error_f = fn(:f1, 3, 4, 5)

    it 'f(3, 4, 5) raises error' do
      expect { error_f.evaluate }.to raise_error 'Cannot evaluate f1 with 3 arguments. Expected 2.'
    end

    ex_g = fn(:g1, 1)

    it 'g(1) does not evaluate' do
      expect(ex_g.evaluate).to be_equal_to ex_g
    end

    ex2_f = fn(:f1, 2, pi)

    it 'f(2, pi) evaluates to pi**3 + 6' do
      expect(ex2_f.evaluate.normalize).to be_equal_to pi**3 + 6
    end

    it '3/4 does not evaluate' do
      expect((3.to_m/4).evaluate).to be_equal_to (3.to_m/4)
    end
  end
end
