require 'spec_helper'
require 'sy'

module Sy
  describe Sy::Operation::Normalization, ', reduce exp and ln (complex)' do
    exp = {
      exp(0)                    => 1,
      exp(ln(:a))               => :a.to_m,
      exp(-ln(:a))              => 1/:a,
      exp(pi*i/2)               => i,
      exp(pi*i)                 => -1,
      exp(3*pi*i/2)             => -i,
      exp(2*pi*i)               => 1,
      exp(-pi*i/2)              => -i,
      exp(-2*pi*i)              => 1,
      exp(-7*pi*i/2)            => i,
      exp(pi*i/2 - ln(:a))      => i/:a,
      e**(pi*i)                 => -1,
    }

    exp.each do |from, to|
      it "reduces '#{from.to_s}' to '#{to.to_s}'" do
        expect(from.normalize).to be_equal_to to
      end
    end

    nored = [
      exp(pi/3),
      exp(-pi*:a),
      exp(sin(:a)),
      exp(ln(:b) + 4),
      exp(2),
      exp(ln(:f) + pi*i/3),
    ];

    nored.each do |n|
      it "does not reduce '#{n.to_s}'" do
        expect(n.normalize).to be_equal_to n
      end
    end
  end

  describe Sy::Operation::Normalization, ', reduce exp (real)' do
    before do
      Sy.setting(:complex_arithmetic, false)
    end

    exp = {
      exp(ln(3))         => 3.to_m,
      exp(-ln(3))        => 1.to_m/3,
      exp(pi*i)          => exp(pi*i),
    }

    exp.each do |from, to|
      it "reduces '#{from.to_s}' to '#{to.to_s}'" do
        expect(from.normalize).to be_equal_to to
      end
    end

    after do
      Sy.setting(:complex_arithmetic, true)
    end
  end
end
