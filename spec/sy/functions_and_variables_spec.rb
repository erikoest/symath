require 'spec_helper'
require 'sy'

module Sy
  describe Sy::Function, ', evaluate' do
    f_def = fn(:f, :x, :y)
    f_exp = :y**3 + :x**2 + 2

    Sy.define_function(f_def, f_exp)

    ex_f = fn(:f, 3, 5)

    it 'f(3, 5) evaluates to 136' do
      expect(ex_f.evaluate.normalize).to be_equal_to 136.to_m
    end

    ex_g = fn(:g, 1)

    it 'g(1) does not evaluate' do
      expect(ex_g.evaluate).to be_equal_to ex_g
    end

    ex2_f = fn(:f, 2, :pi)

    it 'f(2, pi) evaluates to pi**3 + 6' do
      expect(ex2_f.eval.normalize).to be_equal_to :pi.to_m**3 + 6
    end
  end
end
