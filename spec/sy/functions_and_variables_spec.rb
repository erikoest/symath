require 'spec_helper'
require 'sy'

module Sy
  describe Sy::Function, ', evaluate' do
    f_def = fn(:f, :x, :y)
    f_exp = :y**3 + :x**2 + 2

    Sy.define_function(f_def, f_exp)

    ex_f = fn(:f, 3, 5)

    it 'f(3, 5) evaluates to 136' do
      expect(ex_f.expand_formula.normalize).to be_equal_to 136.to_m
    end

    error_f = fn(:f, 3, 4, 5)

    it 'f(3, 4, 5) raises error' do
      expect { error_f.expand_formula }.to raise_error 'Cannot expand f(x,y) with 3 arguments (expected 2)'
    end

    ex_g = fn(:g, 1)

    it 'g(1) does not evaluate' do
      expect(ex_g.evaluate).to be_equal_to ex_g
    end

    ex2_f = fn(:f, 2, :pi)

    it 'f(2, pi) evaluates to pi**3 + 6' do
      expect(ex2_f.evaluate.normalize).to be_equal_to :pi.to_m**3 + 6
    end

    it '3/4 does not evaluate' do
      expect((3.to_m/4).evaluate).to be_equal_to (3.to_m/4)
    end
  end
end
