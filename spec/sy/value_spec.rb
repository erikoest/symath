require 'spec_helper'
require 'sy'

module Sy
  describe Sy::Value, 'Compose without simplify' do
    # Compose without simplify
    before do
      Sy.setting(:compose_with_simplify, false)
    end

    it '2 + 2 does not simplify' do
      expect((2.to_m + 2).class.to_s).to be == 'Sy::Sum'
    end

    it '2 - 2 does not simplify' do
      expect((2.to_m - 2).class.to_s).to be == 'Sy::Sum'
    end

    it '- (- 2) does not simplify' do
      expect((- (- 2.to_m)).class.to_s).to be == 'Sy::Minus'
    end

    it '2*2 does not simplify' do
      expect((2.to_m * 2).class.to_s).to be == 'Sy::Product'
    end

    it '4/1 does not simplify' do
      expect((4.to_m / 1).class.to_s).to be == 'Sy::Fraction'
    end

    it '4**1 does not simplify' do
      expect((4.to_m ** 1).class.to_s).to be == 'Sy::Power'
    end

    after do
      Sy.setting(:compose_with_simplify, true)
    end
  end

  describe Sy::Value, 'Compose with simplify' do
    x = :x.to_m('vector')
    y = :y.to_m('vector')
    z = :a.to_m('vector')
    w = :b.to_m('vector')

    # Test syntactic sugar for integers and symbols
    it '2.to_m + 2 simplifies to number' do
      expect((2.to_m + 2).class.to_s).to be == 'Sy::Number'
    end

    it '2.to_m - 2 simplifies to number' do
      expect((2.to_m - 2).class.to_s).to be == 'Sy::Number'
    end

    it '- (- 2) simplifies to number' do
      expect((- (- 2.to_m)).class.to_s).to be == 'Sy::Number'
    end

    it '2.to_m * 4 simplifies to number' do
      expect((2.to_m + 4).class.to_s).to be == 'Sy::Number'
    end

    it '4/1 simplifies to 4' do
      expect((4.to_m / 1).class.to_s).to be == 'Sy::Number'
    end

    it '4**1 simplifies to 4' do
      expect((4.to_m ** 1).class.to_s).to be == 'Sy::Number'
    end

    it '(-4)**x does not simplify' do
    end

    it '(x/y)/(z/w) simplifies to (x*w)/(y*z)' do
      expect((x.div(y)/z.div(w))).to be_equal_to (x*w)/(y*z)
    end

    it 'x/(z/w) simplifies to (x*w)/z' do
      expect(x/z.div(w)).to be_equal_to (x*w)/z
    end

    it '(x/y)/z simplifies to x/(y*z)' do
      expect(x.div(y)/z).to be_equal_to x/(y*z)
    end

    it '2*(1/a) simplifies to 2/a' do
      expect(2*(1/:a)).to be_equal_to 2/:a
    end

    it '((x^y) + (x^b)) + ((a^b) + (a^x))' do
      a = :x.to_m('vector')
      b = :y.to_m('vector')
      c = :a.to_m('vector')
      d = :b.to_m('vector')

      sum1 = (a^b) + (a^d)
      sum2 = (c^d) + (c^a)
      p = ((((a^b)^(c^d)) + ((a^d)^(c^d))) + (((a^b)^(c^a)) + ((a^d)^(c^a))))
      expect(sum1*sum2).to be_equal_to p
    end

    it '2^:b' do
      expect((2^:b).class.to_s).to be == 'Sy::Product'
    end

    it ':a^:b' do
      expect((:a^:b).class.to_s).to be == 'Sy::Product'
    end

    it 'order of basis vectors and other vectors' do
      x1 = :x1.to_m('vector')
      x2 = :x2.to_m('vector')
      a = :a.to_m('vector')

      expect(x1 < x2).to be
      expect(x1 < a).to be
      expect(a > x1).to be
    end

    it 'variable replacement' do
      a = :a.to_m
      b = :b.to_m

      expect(a.replace(a => (a + 2))).to be_equal_to (a + 2)
      expect(a.replace(b => (a + 2))).to be_equal_to a
    end
  end
end
